import 'package:flutter/material.dart';

class GestureClass {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final Color primaryColor;
  final Color gradientColor;

  const GestureClass({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.primaryColor,
    required this.gradientColor,
  });
}

class GestureClassData {
  static const List<GestureClass> allGestures = [
    GestureClass(
      id: '0',
      name: 'Clap',
      description: 'Both hands come together in a clapping motion',
      imagePath: 'assets/gestures/Clap.jpg',
      primaryColor: Color(0xFF7F49FF),
      gradientColor: Color(0xFF5C2EDB),
    ),
    GestureClass(
      id: '1',
      name: 'Finger Heart',
      description: 'Two fingers form a heart shape',
      imagePath: 'assets/gestures/Finger_Heart.jpg',
      primaryColor: Color(0xFFFF6B9D),
      gradientColor: Color(0xFFC2185B),
    ),
    GestureClass(
      id: '2',
      name: 'Fist',
      description: 'Hand closed into a tight fist',
      imagePath: 'assets/gestures/Fist.jpg',
      primaryColor: Color(0xFFFF9100),
      gradientColor: Color(0xFFE65100),
    ),
    GestureClass(
      id: '3',
      name: 'Heart',
      description: 'Both hands form a heart shape',
      imagePath: 'assets/gestures/Heart.jpg',
      primaryColor: Color(0xFFE91E63),
      gradientColor: Color(0xFF880E4F),
    ),
    GestureClass(
      id: '4',
      name: 'Ok',
      description: 'Thumb and forefinger form a circle',
      imagePath: 'assets/gestures/Ok.jpg',
      primaryColor: Color(0xFF00BCD4),
      gradientColor: Color(0xFF00838F),
    ),
    GestureClass(
      id: '5',
      name: 'Peace',
      description: 'Two fingers raised in a peace sign',
      imagePath: 'assets/gestures/Peace.jpg',
      primaryColor: Color(0xFF4CAF50),
      gradientColor: Color(0xFF1B5E20),
    ),
    GestureClass(
      id: '6',
      name: 'Point',
      description: 'Index finger pointing forward',
      imagePath: 'assets/gestures/Point.jpg',
      primaryColor: Color(0xFF2196F3),
      gradientColor: Color(0xFF0D47A1),
    ),
    GestureClass(
      id: '7',
      name: 'Rock',
      description: 'Fist with index and pinky fingers raised',
      imagePath: 'assets/gestures/Rock.jpg',
      primaryColor: Color(0xFF9C27B0),
      gradientColor: Color(0xFF4A148C),
    ),
    GestureClass(
      id: '8',
      name: 'Stop',
      description: 'Palm facing forward in a stop gesture',
      imagePath: 'assets/gestures/Stop.jpg',
      primaryColor: Color(0xFFF44336),
      gradientColor: Color(0xFFB71C1C),
    ),
    GestureClass(
      id: '9',
      name: 'Thumbs up',
      description: 'Thumb raised upward',
      imagePath: 'assets/gestures/Thumbs_up.jpg',
      primaryColor: Color(0xFF4BC1FA),
      gradientColor: Color(0xFF0277BD),
    ),
  ];
}
