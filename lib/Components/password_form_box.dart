import 'package:flutter/material.dart';

class PasswordFormBox extends StatefulWidget {
  final String label;
  final String hint;
  final bool initialObscureText;

  const PasswordFormBox({
    super.key,
    required this.label,
    required this.hint,
    this.initialObscureText = true,
  });

  @override
  State<PasswordFormBox> createState() => _PasswordFormBoxState();
}

class _PasswordFormBoxState extends State<PasswordFormBox> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.initialObscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            // Changes the icon based on the password visibility state
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            // Toggle the password visibility state
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }
}
