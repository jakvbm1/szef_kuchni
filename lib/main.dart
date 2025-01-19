import 'package:flutter/material.dart';
import 'package:szef_kuchni_v2/views/main_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme(bool isInDarkMode) {
    setState(() {
      _themeMode = isInDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 138, 99, 210),
          brightness: Brightness.light, 
          contrastLevel: 0.5
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: MainView(onThemeChanged: toggleTheme),
    );
  }
}