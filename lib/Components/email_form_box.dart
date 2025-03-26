import 'package:flutter/material.dart';

class EmailFormBox extends StatelessWidget {
  final String label;
  final String hint;

  const EmailFormBox({
    super.key,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
