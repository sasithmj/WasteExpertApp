import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wasteexpert/pages/authentication/login.dart';
import 'package:http/http.dart' as http;
import 'package:wasteexpert/Config.url.dart' as UrlConfig;
import 'package:wasteexpert/pages/home.dart';
import 'package:wasteexpert/pages/main_page.dart';
import 'package:wasteexpert/widgets/authentication/CumtomFormField.dart';

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _rememberMe = false;
  bool _isLoading = false; // Loading state variable

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Set loading state to true
      });

      // Retrieve the values from the controllers
      String name = _nameController.text;
      String email = _emailController.text;
      String mobile = _mobileController.text;
      String password = _passwordController.text;
      String confirmPassword = _confirmPasswordController.text;

      if (password != confirmPassword) {
        // Show an error message if passwords do not match
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false; // Set loading state to false
        });
        return;
      } else {
        var regBody = {
          "name": name,
          "email": email,
          "password": password,
          "mobile": mobile,
        };
        try {
          var response = await http.post(
            Uri.parse(UrlConfig.registrationUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(regBody),
          );

          setState(() {
            _isLoading = false; // Set loading state to false
          });

          if (response.statusCode == 201) {
            // Success response
            var responseBody = jsonDecode(response.body);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Registration successful!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
          } else if (response.statusCode == 400) {
            // User registration failed
            var responseBody = jsonDecode(response.body);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Registration failed: ${responseBody['error']}'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            // Other error responses
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Registration failed. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          setState(() {
            _isLoading = false; // Set loading state to false
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
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registration',
          style: TextStyle(color: Colors.white),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 23, 107, 135),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomFormField(
                      controller: _nameController,
                      label: "Name",
                      hintText: "Enter your name",
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name.';
                        }
                        if (value.length < 2) {
                          return 'Name must be at least 2 characters long.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CustomFormField(
                      controller: _emailController,
                      label: "Email",
                      hintText: "Enter your Email",
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Email.';
                        }
                        final emailRegex =
                            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CustomFormField(
                      controller: _mobileController,
                      label: "Mobile Number",
                      hintText: "Enter your mobile number",
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your mobile number.';
                        }
                        if (value.length != 10 ||
                            !RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Please enter a valid 10-digit mobile number.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CustomFormField(
                      controller: _passwordController,
                      label: "Password",
                      hintText: "Enter your password",
                      obscureText: true,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required.';
                        } else if (value.length < 8) {
                          return 'Password must be at least 8 characters long.';
                        }
                        // if (!RegExp(
                        //         r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
                        //     .hasMatch(value)) {
                        //   return 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character.';
                        // }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CustomFormField(
                      controller: _confirmPasswordController,
                      label: "Confirm Password",
                      hintText: "Re-enter your password",
                      obscureText: true,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password.';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (bool? value) {
                            setState(() {
                              _rememberMe = value!;
                            });
                          },
                        ),
                        const Text("Remember me"),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
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
                      onPressed: _isLoading ? null : _signUp,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                                color: Colors.grey,
                              ),
                            )
                          : const Text(
                              "Sign Up",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already Have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Login()),
                            );
                          },
                          child: const Text(
                            "Login!",
                            style: TextStyle(
                                color: Color.fromARGB(255, 23, 107, 135)),
                          ),
                        ),
                      ],
                    ),
                    // TextButton.icon(
                    //   icon: Image.asset(
                    //     "assets/googleIcon.png",
                    //     width: 24,
                    //     height: 24,
                    //   ),
                    //   onPressed: () => {},
                    //   label: const Text(
                    //     "Continue with google",
                    //     style: TextStyle(color: Colors.black54),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
