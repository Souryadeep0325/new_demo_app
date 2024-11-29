import 'package:flutter/material.dart';

class ThemeService {
  static const Color _primaryColorLight = Colors.blueAccent;
  static const Color _secondaryColorLight = Colors.grey;
  static const Color _tertiaryColorLight = Colors.blueGrey;

  static const Color _primaryColorDark = Colors.deepPurpleAccent;
  static const Color _secondaryColorDark = Colors.grey;
  static const Color _tertiaryColorDark = Colors.blueGrey;

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: _primaryColorLight,
      secondaryHeaderColor: _secondaryColorLight,
      primaryColorLight: _tertiaryColorLight,
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(
        color: _primaryColorLight,
        iconTheme: IconThemeData(color: _tertiaryColorLight),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: _primaryColorDark,
      secondaryHeaderColor: _secondaryColorDark,
      primaryColorLight: _tertiaryColorDark,
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(
        color: _primaryColorDark,
        iconTheme: IconThemeData(color: _tertiaryColorDark),
      ),
    );
  }
}

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData get currentTheme =>
      _isDarkMode ? ThemeService.darkTheme : ThemeService.lightTheme;
}
