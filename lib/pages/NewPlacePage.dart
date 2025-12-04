import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../main.dart';
import '../models/visit.dart';
import '../models/picture.dart';
import '../widgets/Label.dart';
import '../services/place_autocomplete.dart';
import 'dart:convert';
import 'dart:io'; //detectar se é Linux/Android
import 'package:http/http.dart' as http; //chama a API no LINUX
import 'package:path/path.dart' as path;

class NewPlacePage extends StatefulWidget {
  /// null  = estamos criando uma nova visita
  /// não-null = estamos editando uma visita existente
  final Visit? existingVisit;

  const NewPlacePage({
    super.key,
    this.existingVisit,
  });

  bool get isEditing => existingVisit != null;

  @override
  _NewPlacePageState createState() => _NewPlacePageState();
}


class _NewPlacePageState extends State<NewPlacePage> {
  final PlaceAutocompleteService _autocompleteService =
      PlaceAutocompleteService(
        googleApiKey: null, // <-- set your key or null to disable Google
      );

  List<PlaceSuggestion> _suggestions = [];
  bool _showSuggestions = false;
  double? _selectedLat;
  double? _selectedLng;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _ratingsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedCategory;
  final List<String> _selectedImagePaths = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Se veio uma visita para edição, preenche os campos
    if (widget.existingVisit != null) {
      final v = widget.existingVisit!;

      _nameController.text = v.placeName;
      _locationController.text = v.placeLocation;
      _notesController.text = v.description ?? '';
      _dateController.text = v.date;
      _ratingsController.text = v.rating.toString();
      _selectedCategory = v.category;

      _selectedLat = v.latitude;
      _selectedLng = v.longitude;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Ex: Av. Paulista, 1578, São Paulo - SP',
            suffixIcon: Icon(Icons.location_on, color: Colors.grey[400]),
          ),
          style: Theme.of(context).textTheme.labelLarge,
          controller: _locationController,
          onChanged: (value) async {
            // clear previously selected coords when user types
            _selectedLat = null;
            _selectedLng = null;
            if (value.trim().isEmpty) {
              setState(() {
                _suggestions = [];
                _showSuggestions = false;
              });
              return;
            }
            final results = await _autocompleteService.fetch(value);
            setState(() {
              _suggestions = results;
              _showSuggestions = results.isNotEmpty;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'A localização é obrigatória.';
            }
            return null;
          },
        ),
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => Divider(height: 1),
              itemBuilder: (context, i) {
                final s = _suggestions[i];
                return ListTile(
                  title: Text(
                    s.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    // select suggestion
                    String address = s.description;
                    double? lat = s.lat;
                    double? lng = s.lng;

                    // if Google suggestion without coords, fetch details
                    if ((lat == null || lng == null) && s.placeId != null) {
                      final details = await _autocompleteService
                          .getPlaceDetails(s.placeId!);
                      if (details != null) {
                        address = details.description;
                        lat = details.lat;
                        lng = details.lng;
                      }
                    }

                    setState(() {
                      _locationController.text = address;
                      _showSuggestions = false;
                      _suggestions = [];
                      _selectedLat = lat;
                      _selectedLng = lng;
                    });

                    // Optional: autofill name if empty
                    if (_nameController.text.isEmpty) {
                      // try to infer a name from the suggestion (split by comma)
                      final inferred = address.split(',').first;
                      _nameController.text = inferred;
                    }
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white, // Fundo do calendário
              onSurface: Colors.black, // Texto no calendário
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _mostrarOpcoesImagem(BuildContext context) {
    if (Platform.isLinux || Platform.isWindows) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Câmera disponível apenas no Mobile")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galeria'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Câmera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImagePaths.add(pickedFile.path);
        });
      }
    } catch (e) {
      print("Erro ao selecionar imagem: $e");
    }
  }

  Future<String> _saveImagePermanently(String temporaryPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = path.basename(temporaryPath);
    final newPath = '${directory.path}/$name';

    final File imageFile = File(temporaryPath);
    await imageFile.copy(newPath);

    return newPath;
  }

  Future<Map<String, double>?> _getCoordinates(String address) async {
    // 1. LINUX / WINDOWS / MACOS (API OpenStreetMap)
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      try {
        final encodedAddress = Uri.encodeComponent(address);
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json&limit=1',
        );

        final response = await http.get(
          url,
          headers: {'User-Agent': 'maply_app/1.0'},
        );

        if (response.statusCode == 200) {
          final List data = json.decode(response.body);
          if (data.isNotEmpty && data[0] != null) {
            // A API retorna strings mas converti para double por segurança
            final latStr = data[0]['lat'];
            final lonStr = data[0]['lon'];

            if (latStr != null && lonStr != null) {
              return {
                'lat': double.parse(latStr.toString()),
                'lng': double.parse(lonStr.toString()),
              };
            }
          }
        }
      } catch (e) {
        debugPrint("Erro API Linux: $e");
      }
    }
    // MOBILE (Geocoding Nativo)
    else {
      try {
        List<Location> locations = await locationFromAddress(address);
        if (locations.isNotEmpty) {
          return {
            'lat': locations.first.latitude,
            'lng': locations.first.longitude,
          };
        }
      } catch (e) {
        debugPrint("Erro Geocoding Mobile: $e");
      }
    }
    return null;
  }

  Future<void> _save() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  // Se estiver editando, começa com a latitude/longitude que já existem
  double latitude = widget.existingVisit?.latitude ?? 0;
  double longitude = widget.existingVisit?.longitude ?? 0;

  try {
    // Tenta obter as coordenadas pelo endereço digitado
    try {
      final coords = await _getCoordinates(_locationController.text);
      if (coords != null) {
        latitude = coords['lat'] ?? latitude;
        longitude = coords['lng'] ?? longitude;
      }
    } catch (e) {
      print("Erro de Geocoding (não crítico): $e");
    }

    int visitId;

    if (!widget.isEditing) {
      // ---------- CRIAR NOVA VISITA ----------
      final newVisit = Visit(
        placeName: _nameController.text,
        category: _selectedCategory ?? "Outro",
        placeLocation: _locationController.text,
        date: _dateController.text,
        description: _notesController.text,
        rating: double.tryParse(_ratingsController.text) ?? 0,
        latitude: latitude,
        longitude: longitude,
        favorite: false,
      );

      visitId = await database.visitDao.insertVisit(newVisit);
    } else {
      // ---------- ATUALIZAR VISITA EXISTENTE ----------
      final old = widget.existingVisit!;

      final updatedVisit = Visit(
        id: old.id, // mantém o mesmo id
        placeName: _nameController.text,
        category: _selectedCategory ?? "Outro",
        placeLocation: _locationController.text,
        date: _dateController.text,
        description: _notesController.text,
        rating: double.tryParse(_ratingsController.text) ?? old.rating,
        latitude: latitude,
        longitude: longitude,
        favorite: old.favorite,
      );

      await database.visitDao.updateVisit(updatedVisit);
      visitId = old.id!;
    }

    // Salvar APENAS as novas imagens escolhidas agora
    for (String tempPath in _selectedImagePaths) {
      final String permanentPath = await _saveImagePermanently(tempPath);

      final picture = Picture(
        visitId: visitId,
        filePath: permanentPath,
        description: '',
      );

      await database.pictureDao.insertPicture(picture);
    }

    if (mounted) {
      Navigator.of(context).pop(); // fecha o loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Atualizado com sucesso!'
                : 'Salvo com sucesso!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // volta dizendo para quem chamou que algo mudou
      Navigator.of(context).pop(true);
    }
  } catch (e) {
    print("ERRO AO SALVAR: $e");

    if (mounted) {
      Navigator.of(context).pop(); // fecha o loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isEditing ? 'Editar Visita' : 'Registrar Novo Local',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Nome do Local ---
              buildLabel('Nome do Local', context),
              TextFormField(
                decoration: InputDecoration(hintText: 'Ex: Café da Esquina'),
                style: Theme.of(context).textTheme.labelLarge,
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O nome do local é obrigatório.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              buildLabel('Categoria', context),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  hintText: 'Selecione uma categoria',
                  suffixIcon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[400],
                  ),
                ),
                initialValue: _selectedCategory,
                dropdownColor: Colors.white, // Fundo do dropdown BRANCO
                style: Theme.of(context).textTheme.labelLarge,
                items:
                    <String>[
                      'Bar / Pub',
                      'Bibliot. / Livraria',
                      'Cafeteria',
                      'Cinema',
                      'Estádio',
                      'Feira / Mercado',
                      'Hotel/Pousada',
                      'Igreja / Templo',
                      'Monumento',
                      'Museu',
                      'Natureza',
                      'Parque',
                      'Praça',
                      'Praia',
                      'Restaurante',
                      'Shopping',
                      'Teatro',
                      'Outro',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'A categoria é obrigatória.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // --- Data da Visita ---
              buildLabel('Data da Visita', context),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: TextFormField(
                  enabled: false,
                  controller: _dateController,
                  decoration: InputDecoration(
                    hintText: '00/00/0000',
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: Colors.grey[400],
                    ),
                  ),
                  style: Theme.of(context).textTheme.labelLarge,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'A data da visita é obrigatória.';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 20),

              // --- Localização ---
              buildLabel('Localização (Endereço)', context),
              _buildLocationField(),
              SizedBox(height: 20),

              // --- Notas e Memórias ---
              buildLabel('Notas e Memórias', context),
              TextFormField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Descreva sua experiência, o que você sentiu...',
                  alignLabelWithHint: true,
                ),
                style: Theme.of(context).textTheme.labelLarge,
                controller: _notesController,
              ),
              SizedBox(height: 20),

              buildLabel('Avaliação (0-5)', context),
              TextFormField(
                decoration: InputDecoration(hintText: 'Número de 0 - 5'),
                style: Theme.of(context).textTheme.labelLarge,
                controller: _ratingsController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'A avaliação do local é obrigatória.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // --- Recordações Visuais (Botão de Galeria) ---
              buildLabel('Recordações Visuais', context),
              SizedBox(height: 8),
              _buildGalleryButton(context),

              if (_selectedImagePaths.isNotEmpty) ...[
                SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _selectedImagePaths
                        .map((path) => _buildSelectedImagePreview(path))
                        .toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: EdgeInsets.symmetric(vertical: 16.0),
          ),
          child: Text(
            widget.isEditing ? 'Atualizar Visita' : 'Salvar Memória',
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedImagePreview(String imagePath) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.file(
              // USA IMAGE.FILE
              File(imagePath),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedImagePaths.remove(imagePath);
                });
              },
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Novo Widget: Botão que abre a galeria
  Widget _buildGalleryButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _mostrarOpcoesImagem(context),
      icon: Icon(
        Icons.photo_library,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: Text(
        'Adicionar Foto da Galeria',
        style: Theme.of(context).textTheme.labelLarge!.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
