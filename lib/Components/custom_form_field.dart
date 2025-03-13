import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const CustomFormField({
    Key? key,
    required this.label,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 426,
      height: 78,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF192F5D),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1.50,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 30,
            child: Container(
              width: 426,
              height: 48,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0x21192F5D)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: TextFormField(
                controller: controller,
                onChanged: onChanged,
                validator: validator,
                style: const TextStyle(
                  color: Color(0xFF192F5D),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}