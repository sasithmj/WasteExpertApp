import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wasteexpert/Config.url.dart' as UrlConfig;
import 'package:wasteexpert/pages/authentication/register.dart';
import 'package:wasteexpert/pages/main_page.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false; // Loading state variable

  late SharedPreferences _prefs;
  
  void initSharedPref() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _logIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Start loading state
      });

      String email = _emailController.text;
      String password = _passwordController.text;

      var requestBody = {
        "email": email,
        "password": password,
      };

      try {
        var response = await http.post(
          Uri.parse(UrlConfig.loginUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody),
        );

        setState(() {
          _isLoading = false; // End loading state
        });

        if (response.statusCode == 200) {
          var responseBody = jsonDecode(response.body);
          var myToken = responseBody["token"];

          // Store token in SharedPreferences
          await _prefs.setString("token", myToken);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage(token: myToken)),
          );
        } else if (response.statusCode == 401) {
          var responseBody = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${responseBody['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false; // End loading state
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 250,
                    child: Center(
                      child: Image.asset(
                        "assets/horizontal_logo_light.png",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Welcome to WasteExpert.",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Empowering Cleaner, Greener Communities.",
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Email",
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: Color.fromARGB(255, 243, 247, 247),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(color: Colors.black26),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email address.';
                        } else if (!value.contains('@')) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Password",
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: Color.fromARGB(255, 243, 247, 247),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(color: Colors.black26),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required.';
                        } else if (value.length < 8) {
                          return 'Password must be at least 8 characters long.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.black38),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all<Size>(
                        Size(width, 50.0),
                      ),
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color?>(
                        (states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.grey;
                          }
                          return const Color.fromARGB(255, 23, 107, 135);
                        },
                      ),
                    ),
                    onPressed: _isLoading ? null : _logIn,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            "Login",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Registration()),
                          );
                        },
                        child: const Text(
                          "Sign Up!",
                          style: TextStyle(
                              color: Color.fromARGB(255, 23, 107, 135)),
                        ),
                      ),
                    ],
                  ),
                  // const Divider(
                  //   height: 30,
                  //   color: Colors.black26,
                  // ),
                  // const SizedBox(height: 10),
                  // Center(
                  //   child: TextButton.icon(
                  //     onPressed: () {},
                  //     icon: Image.asset(
                  //       "assets/googleIcon.png",
                  //       width: 24,
                  //       height: 24,
                  //     ),
                  //     label: const Text(
                  //       "Continue with Google",
                  //       style: TextStyle(color: Colors.black54),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
