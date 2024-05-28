import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wasteexpert/pages/authentication/register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     'Login',
      //     style: TextStyle(color: Colors.white),
      //   ),
      //   backgroundColor: const Color.fromARGB(255, 23, 107, 135),
      // ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            child: Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 250,
                          child: Center(
                            child: Image.asset(
                              "assets/logo.png",
                              // width: 500,
                            ),
                          ),
                        ),
                        const Text(
                          "Welcome to WastExpert.",
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 24),
                        ),
                        const Text(
                          "Empowering Cleaner, Greener Communities.",
                          style: TextStyle(
                              fontWeight: FontWeight.w300, fontSize: 14),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        const Text(
                          "Email",
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 18),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                25.0), // Adjust the radius as needed
                            color: Color.fromARGB(255, 243, 247, 247),
                          ),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Alex@gmail.com',
                              hintStyle: TextStyle(color: Colors.black26),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15.0), // Adjust padding as needed
                            ),
                            onSaved: (String? value) {
                              // This optional block of code can be used to run
                              // code when the user saves the form.
                            },
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an email address.';
                              } else if (!value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 26,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Password",
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 18),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                25.0), // Adjust the radius as needed
                            color: const Color.fromARGB(255, 243, 247, 247),
                          ),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: '*********',
                              hintStyle: TextStyle(color: Colors.black26),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15.0), // Adjust padding as needed
                            ),
                            onSaved: (String? value) {
                              // This optional block of code can be used to run
                              // code when the user saves the form.
                            },
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required.';
                              } else if (value.length < 8) {
                                return 'Password must be at least 8 characters long.';
                              } else if (!value.contains(
                                  RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                                return 'Password must contain at least one special character.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => {},
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.black38),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all<Size>(
                          Size(width, 50.0), // Button width and height
                        ),
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                          (states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors
                                  .grey; // Color when button is disabled
                            }
                            return const Color.fromARGB(255, 23, 107,
                                135); // Color when button is enabled
                          },
                        ),
                      ),
                      onPressed: () => {},
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't Have an account?"),
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
                    const Row(
                      children: [
                        Expanded(
                          child: Divider(
                            height: 28,
                            color: Colors.black26,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("OR"),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.black26,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      icon: Image.asset(
                        "assets/googleIcon.png",
                        width: 24,
                        height: 24,
                      ),
                      onPressed: () => {},
                      label: const Text(
                        "Continue with google",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
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
