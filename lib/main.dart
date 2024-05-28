import 'package:flutter/material.dart';
import 'package:wasteexpert/pages/authentication/login.dart';
import 'package:wasteexpert/pages/authentication/register.dart';
import 'package:wasteexpert/pages/home.dart';
import 'package:wasteexpert/pages/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 123, 83, 193)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
