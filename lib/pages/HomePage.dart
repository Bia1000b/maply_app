import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../models/visit.dart';
import '../models/place_filters.dart';
import '../widgets/PlaceCard.dart';
import '../widgets/FilterModal.dart';
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

  String _searchText = "";
  PlaceFilters _filters = PlaceFilters();

  final List<String> _categories = [
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
  ];

  @override
  void initState() {
    super.initState();
    getVisits();
  }

  Future<void> getVisits() async {
    try {
      final visits = await database.visitDao.findAllVisits();
      visits.sort((a, b) {
        try {
          DateFormat format = DateFormat("dd/MM/yyyy");
          DateTime dateA = format.parse(a.date);
          DateTime dateB = format.parse(b.date);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      if (mounted) {
        setState(() {
          _allVisits = visits;
          _isLoading = false;
          _applyFilters();
        });
      }
    } catch (e) {
      debugPrint("ERRO AO CARREGAR: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<Visit> results = _allVisits;

    // Texto
    if (_searchText.isNotEmpty) {
      results = results
          .where(
            (visit) =>
                visit.placeName.toLowerCase().contains(
                  _searchText.toLowerCase(),
                ) ||
                visit.placeLocation.toLowerCase().contains(
                  _searchText.toLowerCase(),
                ),
          )
          .toList();
    }

    // Categoria
    if (_filters.category != null) {
      results = results
          .where((visit) => visit.category == _filters.category)
          .toList();
    }

    // Nota
    if (_filters.minRating > 0) {
      results = results
          .where((visit) => visit.rating >= _filters.minRating)
          .toList();
    }

    // Data (Range)
    if (_filters.dateRange != null) {
      DateFormat format = DateFormat("dd/MM/yyyy");
      results = results.where((visit) {
        try {
          DateTime visitDate = format.parse(visit.date);
          return visitDate.isAfter(
                _filters.dateRange!.start.subtract(const Duration(days: 1)),
              ) &&
              visitDate.isBefore(
                _filters.dateRange!.end.add(const Duration(days: 1)),
              );
        } catch (e) {
          return false;
        }
      }).toList();
    }

    setState(() {
      _filteredVisits = results;
    });
  }

  Future<void> _openFilterModal() async {
    final result = await showModalBottomSheet<PlaceFilters>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          FilterModal(currentFilters: _filters, categories: _categories),
    );
    if (result != null) {
      setState(() {
        _filters = result;
        _applyFilters();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.location_pin,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MapPage(visits: _allVisits)),
          ),
        ),
        title: Center(
          child: Text(
            'Meus Lugares',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
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
                    MaterialPageRoute(builder: (_) => const NewPlacePage()),
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      _searchText = val;
                      _applyFilters();
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _buildFilterButton(),
              ],
            ),
          ),

          // --- Chips de Filtros Ativos ---
          if (_filters.hasActiveFilters) _buildActiveFiltersChips(),

          Expanded(child: _buildListContent()),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    bool isActive = _filters.hasActiveFilters;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: IconButton(
            icon: Icon(
              Icons.filter_list,
              color: isActive ? Colors.white : Colors.black,
            ),
            onPressed: _openFilterModal,
          ),
        ),
        if (isActive)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActiveFiltersChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_filters.category != null)
              _buildChip(
                _filters.category!,
                () => setState(() {
                  _filters.category = null;
                  _applyFilters();
                }),
              ),
            if (_filters.minRating > 0)
              _buildChip(
                "Nota >= ${_filters.minRating.toInt()}",
                () => setState(() {
                  _filters.minRating = 0.0;
                  _applyFilters();
                }),
              ),
            if (_filters.dateRange != null)
              _buildChip(
                "Período definido",
                () => setState(() {
                  _filters.dateRange = null;
                  _applyFilters();
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(label: Text(label), onDeleted: onDelete),
    );
  }

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
            Icon(Icons.map_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "Nenhum lugar encontrado",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
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
            return GestureDetector(
              onTap: () async {
            final changed = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => DetailPage(visitId: visit.id!),
              ),
            );

            // Se a DetailPage avisar que algo mudou, recarrega a lista
            if (changed == true) {
              getVisits();
            }
          },
              child: PlaceCard(
                name: visit.placeName,
                location: visit.placeLocation,
                date: visit.date,
                imagePath: snapshot.data,
              ),
            );
          },
        );
      },
    );
  }
}
