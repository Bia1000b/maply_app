import 'package:flutter/material.dart';

class PlaceFilters {
  String? category;
  DateTimeRange? dateRange;
  double minRating;

  PlaceFilters({this.category, this.dateRange, this.minRating = 0.0});

  bool get hasActiveFilters =>
      category != null || dateRange != null || minRating > 0;

  void clear() {
    category = null;
    dateRange = null;
    minRating = 0.0;
  }

  PlaceFilters copy() {
    return PlaceFilters(
      category: category,
      dateRange: dateRange,
      minRating: minRating,
    );
  }
}
