import 'package:SeeLight/main_screen.dart';
import 'package:flutter/material.dart';

ThemeData themeMode = ThemeData.light();

void main() {
  runApp(MaterialApp(
    theme: themeMode,
    home: MainScreenWidget()
  ));
}
