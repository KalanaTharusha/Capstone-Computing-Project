import 'package:flutter/material.dart';

class BoxTextField extends StatelessWidget {

  final TextEditingController controller;
  final String hintText;
  final String ?errorText;
  final bool isObscure;
  final Widget? suffix;

  const BoxTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.errorText,
    required this.isObscure,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: TextStyle(
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),),
        suffixIcon: suffix
      ),
    );
  }
}
