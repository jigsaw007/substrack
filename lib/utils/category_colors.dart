import 'package:flutter/material.dart';

class CategoryColors {
  // Define a base color palette (you can expand this)
  static final List<Color> _palette = [
    Colors.teal,
    Colors.blue,
    Colors.deepPurple,
    Colors.orange,
    Colors.green,
    Colors.pink,
    Colors.indigo,
    Colors.redAccent,
    Colors.cyan,
    Colors.amber,
  ];

  static final Map<String, Color> _categoryMap = {};

  /// Returns a consistent color for a given category name.
  static Color forCategory(String category) {
    if (category.isEmpty) category = 'Other';
    if (_categoryMap.containsKey(category)) {
      return _categoryMap[category]!;
    }

    // Assign next available color from palette cyclically
    final color = _palette[_categoryMap.length % _palette.length];
    _categoryMap[category] = color;
    return color;
  }
}
