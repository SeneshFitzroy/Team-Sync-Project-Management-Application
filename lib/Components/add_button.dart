import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double width;

  const AddButton({
    super.key,
    this.onPressed,
    this.text = 'Add New Task',
    this.backgroundColor = const Color(0xFF192F5D),
    this.textColor = Colors.white,
    this.width = 205,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(50),
          child: Stack(
            children: [
              // Button background with shadow
              Container(
                width: width,
                height: 56,
                decoration: ShapeDecoration(
                  color: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              
              // Add icon
              Positioned(
                left: 32,
                top: 16,
                child: Icon(
                  Icons.add,
                  color: textColor,
                  size: 24,
                ),
              ),
              
              // Button text
              Positioned(
                left: 64,
                top: 16,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}