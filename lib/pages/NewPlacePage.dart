import 'package:flutter/material.dart';

import '../widgets/Label.dart';
class NewPlacePage extends StatefulWidget {
  @override
  _NewPlacePageState createState() => _NewPlacePageState();
}

class _NewPlacePageState extends State<NewPlacePage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  TextEditingController _dateController = TextEditingController();
  List<String> _selectedImagePaths = [];

  @override
  void dispose() {
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

  // funcao de salvar
  void _saveMemory() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Aqui envia os dados p/ o SQLite
      print("Memória Salva! Dados válidos.");
      // Navigator.pop(context); // Isso fechar a tela após salvar
    } else {
      print("Erro de validação. Preencha todos os campos obrigatórios.");
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
                value: _selectedCategory,
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
                // Notas são opcionais, então não precisa de validator
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