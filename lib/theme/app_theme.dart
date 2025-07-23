import 'package:flutter/material.dart';

class AppTheme {
  static final Color _primaryColor = const Color(0xFFEAE7DC);
  static final Color _accentColor = const Color(0xFFD8C3A5);
  static final Color _textColor = const Color(0xFF8E8D8A);
  static final Color _backgroundColor = const Color(0xFFE9E9E9);

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: _backgroundColor,
    primaryColor: _primaryColor,
    colorScheme: ColorScheme.light(
      primary: _primaryColor,
      secondary: _accentColor,
      onPrimary: _textColor,
      onSecondary: _textColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _primaryColor,
      foregroundColor: _textColor,
      elevation: 0,
      iconTheme: IconThemeData(color: _textColor),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: _textColor),
    ),
    cardTheme: CardThemeData(
      color: _primaryColor,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static final Color _darkPrimaryColor = const Color(0xFF2C3E50);
  static final Color _darkAccentColor = const Color(0xFFE74C3C);
  static final Color _darkTextColor = const Color(0xFFECF0F1);
  static final Color _darkBackgroundColor = const Color(0xFF34495E);

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: _darkBackgroundColor,
    primaryColor: _darkPrimaryColor,
    colorScheme: ColorScheme.dark(
      primary: _darkPrimaryColor,
      secondary: _darkAccentColor,
      onPrimary: _darkTextColor,
      onSecondary: _darkTextColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _darkPrimaryColor,
      foregroundColor: _darkTextColor,
      elevation: 0,
      iconTheme: IconThemeData(color: _darkTextColor),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: _darkTextColor,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: _darkTextColor),
    ),
    cardTheme: CardThemeData(
      color: _darkPrimaryColor,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
