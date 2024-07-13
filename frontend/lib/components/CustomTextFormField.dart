import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {

  final String label;
  final String value;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(),
        ),
      ),
    );
  }
}
