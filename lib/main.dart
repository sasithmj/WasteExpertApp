import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wasteexpert/pages/authentication/login.dart';
import 'package:wasteexpert/pages/authentication/register.dart';
import 'package:wasteexpert/pages/home.dart';
import 'package:wasteexpert/pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(
    token: prefs.getString("token"),
  ));
}

class MyApp extends StatelessWidget {
  final token;
  const MyApp({@required this.token, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 123, 83, 193)),
        useMaterial3: true,
      ),
      home: JwtDecoder.isExpired(token) == false
          ? HomePage(token: token)
          : const Login(),
    );
  }
}
