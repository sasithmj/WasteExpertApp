// custom_form_field.dart
import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLength;
  final String? Function(String?)? validator;

  const CustomFormField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLength = 0,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: const Color.fromARGB(255, 243, 247, 247),
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.black26),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15.0),
            ),
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLength: maxLength != 0 ? maxLength : null,
            validator: validator,
          ),
        ),
      ],
    );
  }
}
