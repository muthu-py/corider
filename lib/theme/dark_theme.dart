import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF135BEC),
    surface: Color(0xFF101622),
    onSurface: Colors.white,
  ),
  cardTheme: const CardThemeData(
    color: Color(0xFF1A2230),
    surfaceTintColor: Colors.transparent,
  ),
  scaffoldBackgroundColor: const Color(0xFF101622),
  textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme),
  useMaterial3: true,
);
