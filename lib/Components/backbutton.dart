import 'package:flutter/material.dart';

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),  // Using standard Flutter icon instead of image
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
