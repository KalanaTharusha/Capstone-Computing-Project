import 'package:flutter/material.dart';

class BoxTextButton extends StatelessWidget {
  final String title;
  final Color btnColor;
  final Color txtColor;
  final Function() onTap;

  const BoxTextButton({
    super.key,
    required this.title,
    required this.btnColor,
    required this.txtColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: btnColor),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              title,
              style: TextStyle(
                color: txtColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
