import 'package:flutter/material.dart';

import '../main.dart';
import '../models/place.dart';
import '../widgets/PlaceCard.dart';
import 'NewPlacePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  List<Place> _places = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getPlaces();
  }

  Future<void> getPlaces() async {
    try {
      final places = await database.placeDao.findAllPlaces();

      if (mounted) {
        setState(() {
          _places = places;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("ERRO AO CARREGAR: $e");
      if (mounted) {
        setState(() {
          _places = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.location_pin, color: Theme.of(context).colorScheme.primary),
          onPressed: () {
            print('Adicionar novo lugar');
          },
        ),
        title: Center(child: Text('Meus Lugares', style: Theme.of(context).textTheme.headlineSmall)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewPlacePage(),
                    ),
                  );
                  getPlaces();
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 16, top: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.black),
                    onPressed: () {
                      print('Abrir filtros');
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildListContent(),
          ),
        ],
      ),
    );
  }

  // Metodo separado para organizar a lógica de exibição
  Widget _buildListContent() {
    // 1. Estado de Carregamento
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    // 2. Estado Vazio (Sem dados)
    if (_places.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                Icons.map_outlined,
                size: 80,
                color: Colors.grey[300]
            ),
            const SizedBox(height: 16),
            Text(
              "Nenhum lugar encontrado",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Adicione um novo lugar clicando no +",
            ),
          ],
        ),
      );
    }

    // 3. Lista com Dados
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _places.length,
      itemBuilder: (context, index) {
        final place = _places[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: PlaceCard(
            name: place.name,
            location: place.location,
            date: "Data aqui",
            imagePath: null,   // Substituir pela imagem
          ),
        );
      },
    );
  }
}