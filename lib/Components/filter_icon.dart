import 'package:flutter/material.dart';

class FilterIcon extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color iconColor;

  const FilterIcon({
    Key? key,
    this.onPressed,
    this.iconColor = const Color(0xFF192F5D),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.filter_list,
        color: iconColor,
      ),
      onPressed: onPressed,
      tooltip: 'Filter',
    );
  }
}