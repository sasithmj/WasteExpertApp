import 'package:flutter/material.dart';
import 'package:wasteexpert/pages/authentication/login.dart';

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _formKey = GlobalKey<FormState>();

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
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Name",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 20),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: Color.fromARGB(255, 243, 247, 247),
                          ),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Enter your name',
                              hintStyle: TextStyle(color: Colors.black26),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 15.0),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name.';
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
                          "Mobile Number",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 20),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: Color.fromARGB(255, 243, 247, 247),
                          ),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Enter your mobile number',
                              hintStyle: TextStyle(color: Colors.black26),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 15.0),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your mobile number.';
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
                              fontWeight: FontWeight.w600, fontSize: 20),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: const Color.fromARGB(255, 243, 247, 247),
                          ),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Enter your password',
                              hintStyle: TextStyle(color: Colors.black26),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 15.0),
                            ),
                            obscureText: true,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required.';
                              } else if (value.length < 8) {
                                return 'Password must be at least 8 characters long.';
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
                          "Confirm Password",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 20),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: const Color.fromARGB(255, 243, 247, 247),
                          ),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Re-enter your password',
                              hintStyle: TextStyle(color: Colors.black26),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 15.0),
                            ),
                            obscureText: true,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password.';
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
                      children: [
                        Checkbox(
                          value:
                              false, // Change this to store the checkbox value
                          onChanged: (bool? value) {
                            // Handle checkbox state change
                          },
                        ),
                        Text("Remember me"),
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
                      onPressed: () => {},
                      child: const Text(
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
