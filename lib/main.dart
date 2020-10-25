import 'package:SeeLight/main_screen.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';




class SeeLightApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => ThemeData.light(),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          theme: theme,
          title: "SeeLight",
          home: MainScreenWidget(),
        );
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //       return MaterialApp(
  //         theme: ThemeData.light(),
  //         home: MainScreenWidget()
  //       );
  // }
}



void main() {
  runApp(SeeLightApp());
}
