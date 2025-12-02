import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/place_filters.dart';

class FilterModal extends StatefulWidget {
  final PlaceFilters currentFilters;
  final List<String> categories;

  const FilterModal({
    super.key,
    required this.currentFilters,
    required this.categories,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late PlaceFilters _tempFilters;

  @override
  void initState() {
    super.initState();
    _tempFilters = widget.currentFilters.copy();
  }

  String _getRatingLabel(double rating) {
    if (rating == 0) return "Qualquer";
    if (rating == 5) return "5 estrelas";
    return "${rating.toInt()}+ estrelas";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            "Filtrar Lugares",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),

          Text("Categoria", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            value: _tempFilters.category,
            hint: const Text("Todas as categorias"),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text("Todas as categorias"),
              ),
              ...widget.categories.map(
                (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
              ),
            ],
            onChanged: (val) => setState(() => _tempFilters.category = val),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Nota Mínima",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                _getRatingLabel(_tempFilters.minRating),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: _tempFilters.minRating,
            min: 0,
            max: 5,
            divisions: 5,
            label: _tempFilters.minRating.round().toString(),
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) => setState(() => _tempFilters.minRating = val),
          ),
          const SizedBox(height: 10),

          Text("Data da Visita", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.date_range),
            label: Text(
              _tempFilters.dateRange == null
                  ? "Selecionar Período"
                  : "${DateFormat('dd/MM').format(_tempFilters.dateRange!.start)} até ${DateFormat('dd/MM').format(_tempFilters.dateRange!.end)}",
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDateRange: _tempFilters.dateRange,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: Theme.of(context).colorScheme.primary,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() => _tempFilters.dateRange = picked);
              }
            },
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    _tempFilters.clear();
                    Navigator.pop(context, _tempFilters);
                  },
                  child: const Text("Limpar"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, _tempFilters);
                  },
                  child: const Text(
                    "Aplicar",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
