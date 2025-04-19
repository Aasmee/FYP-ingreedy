import 'package:flutter/material.dart';

class Textfield extends StatelessWidget {
  final String label;
  final Color labelColor;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final String? Function(String?)? validator;

  const Textfield({
    super.key,
    required this.label,
    this.labelColor = Colors.black,
    this.hintText = '',
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: labelColor)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
