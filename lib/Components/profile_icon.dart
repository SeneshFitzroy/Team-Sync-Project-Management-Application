import 'package:flutter/material.dart';

class ProfileIcon extends StatelessWidget {
  final double size;
  final Function()? onPressed;
  final String? imageUrl;
  final Color backgroundColor;
  final Color iconColor;
  
  const ProfileIcon({
    Key? key, 
    this.size = 36,
    this.onPressed,
    this.imageUrl,
    this.backgroundColor = Colors.black,
    this.iconColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onPressed ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile clicked')),
          );
        },
        child: imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(size / 2),
                child: Image.network(
                  imageUrl!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    color: iconColor,
                    size: size * 0.6,
                  ),
                ),
              ),
      ),
    );
  }
}