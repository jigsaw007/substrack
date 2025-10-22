import 'package:flutter/material.dart';

const _primary = Color(0xFF6C63FF); // purple accent
const _surface = Color(0xFFF5F7FA); // soft bg
const _teal = Color(0xFF1ABC9C);

final lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: _primary),
  scaffoldBackgroundColor: _surface,
  useMaterial3: true,
  fontFamily: 'Poppins',
);

final darkTheme = ThemeData.dark(useMaterial3: true).copyWith(
  colorScheme: ColorScheme.fromSeed(
    seedColor: _primary,
    brightness: Brightness.dark,
  ),
);
