import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF135BEC),
    surface: Color(0xFFF6F6F8),
    onSurface: Colors.black,
  ),
  cardTheme: const CardThemeData(
    color: Colors.white,
    surfaceTintColor: Colors.transparent,
  ),
  scaffoldBackgroundColor: const Color(0xFFF6F6F8),
  textTheme: GoogleFonts.manropeTextTheme(),
  useMaterial3: true,
);
