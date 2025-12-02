import 'package:flutter/material.dart';

import '../main.dart';
import '../models/visit.dart';
import '../widgets/PlaceCard.dart';
import 'NewPlacePage.dart';
import 'MapPage.dart';
import 'DetailPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  List<Visit> _allVisits = [];
  List<Visit> _filteredVisits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getVisits();
  }

  Future<void> getVisits() async {
    try {
      final visits = await database.visitDao.findAllVisits();

      if (mounted) {
        setState(() {
          _allVisits = visits;
          _filteredVisits = visits;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("ERRO AO CARREGAR: $e");
      if (mounted) {
        setState(() {
          _allVisits = [];
          _filteredVisits = [];
          _isLoading = false;
        });
      }
    }
  }

  void _runFilter(String enteredKeyword) {
    List<Visit> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allVisits;
    } else {
      results = _allVisits
          .where((visit) =>
      visit.placeName.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          visit.placeLocation.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredVisits = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.location_pin, color: Theme.of(context).colorScheme.primary),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapPage(visits: _allVisits),
              ),
            );
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
                  getVisits();
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
                    onChanged: (value) => _runFilter(value),
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
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (_filteredVisits.isEmpty) {
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

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _filteredVisits.length,
      itemBuilder: (context, index) {
        final visit = _filteredVisits[index];

        return FutureBuilder<String?>(
          future: database.pictureDao.findFirstPicturePath(visit.id!),
          builder: (context, snapshot) {
            final String? imagePath = snapshot.data;
            
            // ← AQUI COLOQUEI O GestureDetector para abrir o DetailPage
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailPage(visitId: visit.id!), // ← passa só o id
                  ),
                );
              },
              child: PlaceCard(
                name: visit.placeName,
                location: visit.placeLocation,
                date: visit.date,
                imagePath: imagePath,
              ),
            );
          },
        );
      },
    );
  }
}
