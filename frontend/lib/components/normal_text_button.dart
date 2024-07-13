import 'package:flutter/material.dart';

class NormalTextButton extends StatelessWidget {
  final String text;
  final Color txtColor;
  final Function() onTap;

  const NormalTextButton({
    super.key,
    required this.text,
    required this.txtColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: const ButtonStyle(
        overlayColor: MaterialStatePropertyAll(Colors.transparent),
      ),
      child: Text(
        text,
        style: TextStyle(color: txtColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
