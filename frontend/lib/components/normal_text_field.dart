import 'package:flutter/material.dart';

class NormalTextField extends StatelessWidget {

  final TextEditingController controller;
  final String label;
  final bool isObscure;
  final String ?errorText;
  final Widget? suffix;

  const NormalTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.isObscure,
    required this.errorText,
    this.suffix
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, errorText: errorText, suffixIcon: suffix),
      obscureText: isObscure,
    );
  }
}
