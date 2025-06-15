import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    onSurface: Colors.black,
    primary: Color(0xff87E64B)
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,  
    foregroundColor: Colors.black,   
    elevation: 0, 
    surfaceTintColor: Colors.transparent,                 
  ),
  useMaterial3: true,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color(0xfff5f5f5),
    selectedItemColor: Color(0xff171717),
    unselectedItemColor: Color(0xffa3a3a3),
    showUnselectedLabels: true,
  ),
  hintColor: Color(0xffe5e5e5),
  // splashColor: Colors.transparent,

);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Color(0xff0a0a0a),
    onSurface: Colors.white,
    primary: Color(0xff87E64B)
  ),
   appBarTheme: AppBarTheme(
    backgroundColor: Color(0xff0a0a0a),
    foregroundColor: Colors.white,
    elevation: 0,
    surfaceTintColor: Colors.transparent,                 
  ),
  useMaterial3: true,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color(0xff0a0a0a),
    selectedItemColor: Color(0xfffafafa),
    unselectedItemColor: Color(0xff737373),
    showUnselectedLabels: true,
    elevation: 0.1,
    // enableFeedback: false,
  ),
  hintColor: Color(0xff737373),
  // splashColor: Colors.transparent,

);
