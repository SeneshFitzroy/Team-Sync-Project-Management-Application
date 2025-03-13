import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const FilterButton({
    Key? key,
    this.onPressed,
    this.text = 'Project Tasks',
    this.backgroundColor = const Color(0xFF192F5D),
    this.textColor = const Color(0xFFF7F8FB),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 167,
      height: 50,
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(50),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                height: 1.50,
              ),
            ),
          ),
        ),
      ),
    );
  }
}