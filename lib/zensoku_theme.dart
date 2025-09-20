// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class ZensokuTheme {
  static const Color primaryColor = Color(0xFF7f5af0);
  static const Color secondaryColor = Color(0xFF2cb67d);
  static const Color accentColor = Color(0xFF72757e);
  static const Color backgroundColorLight = Color(0xFFFFFFFF);
  static const Color backgroundColorDark = Color(0xFF16161a);

  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: primaryColor,
    primaryContainer: primaryColor,
    secondary: secondaryColor,
    secondaryContainer: secondaryColor,
    error: Colors.red, // Customize error color if needed
    onPrimary: Colors.black, // Customize text color on primary color if needed
  );

  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: primaryColor,
    primaryContainer: primaryColor,
    secondary: secondaryColor,
    secondaryContainer: secondaryColor,
    surface: backgroundColorDark,
    error: Colors.red, // Customize error color if needed
    onPrimary: Colors.white, // Customize text color on primary color if needed
    onSecondary:
        Colors.white, // Customize text color on secondary color if needed
    onError: Colors.white, // Customize text color on error color if needed
  );

  static ThemeData darkTheme = ThemeData(
      colorScheme: darkColorScheme,
      cardTheme: CardTheme(color: HexColor('#b1b2b5')),
      useMaterial3: true);

  static ThemeData lightTheme = ThemeData(
      colorScheme: lightColorScheme,
      cardTheme: CardTheme(color: HexColor('#b1b2b5')),
      useMaterial3: true);

  static Color cardBackgroundColour = HexColor('#94a1b2');

  static TextStyle darkHeading1Style = TextStyle(
      fontSize: 30, fontWeight: FontWeight.bold, color: HexColor('#223248'));
  static TextStyle lightHeading2Style = const TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white);

  static Color baseHeadingColor = HexColor('#223248');
  static double baseHeading1Size = 30;
}
