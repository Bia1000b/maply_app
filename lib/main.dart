import 'package:flutter/material.dart';

import 'pages/HomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maply',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 2,
        ),
        textTheme: TextTheme(
          headlineSmall: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.grey[700], fontSize: 12),
          labelLarge: TextStyle(color: Colors.black, fontSize: 14),
        ),
        colorScheme: ColorScheme.light(
          primary: Color.fromARGB(255, 135, 0, 4), // Cor principal mantida (vermelho)
          secondary: Color.fromARGB(255, 172, 48, 50),
          surface: Colors.white, // Superfícies (Cards, etc.) BRANCAS
          onSurface: Colors.black, // Conteúdo em superfícies (texto, ícones)
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF0F0F0),
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      home: HomePage(),
    );
  }
}