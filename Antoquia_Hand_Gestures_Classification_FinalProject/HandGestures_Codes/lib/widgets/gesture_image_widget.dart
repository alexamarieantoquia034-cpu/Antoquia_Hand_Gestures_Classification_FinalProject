import 'package:flutter/material.dart';

class GestureImageWidget extends StatelessWidget {
  final String imagePath;
  final double size;

  const GestureImageWidget({
    super.key,
    required this.imagePath,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.broken_image,
          size: size,
          color: Colors.grey,
        );
      },
    );
  }
}
