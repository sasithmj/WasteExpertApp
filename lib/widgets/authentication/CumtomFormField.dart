import 'package:flutter/material.dart';

class CustomFormField extends StatefulWidget {
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
  _CustomFormFieldState createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: const Color.fromARGB(255, 243, 247, 247),
          ),
          child: TextFormField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: Colors.black26),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical:
                    16.0, // Add vertical padding to align text with suffix
              ),
              suffixIcon: widget.obscureText
                  ? Padding(
                      padding: const EdgeInsets.only(
                          right: 12.0), // Adjust right padding
                      child: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    )
                  : null,
            ),
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            maxLength: widget.maxLength != 0 ? widget.maxLength : null,
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}
