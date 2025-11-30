import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/visit.dart';
import '../widgets/Label.dart';
import 'dart:convert';
import 'dart:io'; //detectar se é Linux/Android
import 'package:http/http.dart' as http; //chama a API no LINUX

class NewPlacePage extends StatefulWidget {
  const NewPlacePage({super.key});

  @override
  _NewPlacePageState createState() => _NewPlacePageState();
}

class _NewPlacePageState extends State<NewPlacePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _ratingsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedCategory;
  final List<String> _selectedImagePaths = [];

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
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

  // abertura da galeria
  void _openGallery() {
    //colocar pacote image_picker para isso.
    // Simulando a adição de um caminho de imagem (para teste)
    setState(() {
      _selectedImagePaths.add('assets/new_image_${_selectedImagePaths.length}.jpg');
    });
    print('Abrir Galeria do Celular');
  }

  Future<Map<String, double>?> _getCoordinates(String address) async {
    // 1. LINUX / WINDOWS / MACOS (API OpenStreetMap)
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      try {
        final encodedAddress = Uri.encodeComponent(address);
        final url = Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json&limit=1');
        
        final response = await http.get(url, headers: {
          'User-Agent': 'maply_app/1.0',
        });

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

  Future<void> _saveMemory() async {
    if (_formKey.currentState!.validate()) {
      // mostra o loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      double latitude = 0;
      double longitude = 0;

      try {
        // busca as coordenadas
        final coords = await _getCoordinates(_locationController.text);
        
        // Verifica se veio null antes de tentar acessar
        if (coords != null) {
          latitude = coords['lat'] ?? 0; // Se for null usa 0
          longitude = coords['lng'] ?? 0;
        }

      } catch (e) {
        print("Erro ao buscar coordenadas: $e");
        // segue com 0.0, sem impedir o salvamento
      } finally {
        // garante que o loading seja fechado
        if (mounted) {
          Navigator.of(context).pop(); 
        }
      }
      try {
        // Criando o objeto Visit com os dados do formulário
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

        // Chamando o DAO para inserir no banco
        await database.visitDao.insertVisit(newVisit);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lugar salvo com sucesso!'), backgroundColor: Colors.green),
          );
          // Fecha a tela e volta para a Home
          Navigator.pop(context);
        }
      } catch (e) {
        print("Erro ao salvar: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Erro ao salvar os dados: $e'), backgroundColor: Colors.red),
          );
        }
      }
    } else {
        print("Erro de validação.");
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
        title: Text('Registrar Novo Local', style: Theme.of(context).textTheme.titleLarge),
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
                decoration: InputDecoration(
                  hintText: 'Ex: Café da Esquina',
                ),
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
                  suffixIcon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
                ),
                initialValue: _selectedCategory,
                dropdownColor: Colors.white, // Fundo do dropdown BRANCO
                style: Theme.of(context).textTheme.labelLarge,
                items: <String>['Cafeteria', 'Restaurante', 'Parque', 'Museu', 'Hotel', 'Praia', 'Outro']
                    .map<DropdownMenuItem<String>>((String value) {
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
              buildLabel('Data da Visita',context),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: TextFormField(
                  enabled: false,
                  controller: _dateController,
                  decoration: InputDecoration(
                    hintText: '00/00/0000',
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[400]),
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
              buildLabel('Localização (Endereço)',context),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Ex: Av. Paulista, 1578, São Paulo - SP',
                  suffixIcon: Icon(Icons.location_on, color: Colors.grey[400]),
                ),
                style: Theme.of(context).textTheme.labelLarge,
                controller: _locationController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'A localização é obrigatória.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // --- Notas e Memórias ---
              buildLabel('Notas e Memórias',context),
              TextFormField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Descreva sua experiência, o que você sentiu...',
                  alignLabelWithHint: true,
                ),
                style: Theme.of(context).textTheme.labelLarge,
                controller: _notesController,
                // Notas são opcionais, então não precisa de validator
              ),
              SizedBox(height: 20),

              buildLabel('Avaliação (0-5)', context),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Número de 0 - 5',
                ),
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
                    children: _selectedImagePaths.map((path) => _buildSelectedImagePreview(path)).toList(),
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
          onPressed: _saveMemory,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: EdgeInsets.symmetric(vertical: 16.0),
          ),
          child: Text(
            'Salvar Memória',
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

  // Widget de Prévia da Imagem (mantido para fins de demonstração da lista)
  Widget _buildSelectedImagePreview(String imagePath) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              width: 100,
              height: 100,
              color: Color(0xFFF0F0F0), // Cor de fundo claro para simular a imagem
              child: Center(child: Icon(Icons.image, color: Colors.grey)),
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
                print('Remover imagem: $imagePath');
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
      onPressed: _openGallery,
      icon: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
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
        side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}