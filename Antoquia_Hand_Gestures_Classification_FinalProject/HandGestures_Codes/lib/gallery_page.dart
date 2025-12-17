import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart' show GestureHomePage, analytics;

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _openGallery();
  }

  Future<void> _openGallery() async {
    try {
      await analytics.logEvent(name: 'gallery_opened');
      
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
      
      if (!mounted) return;
      
      if (picked != null) {
        final file = File(picked.path);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GestureHomePage(
              imageFile: file,
              imageSource: 'gallery',
            ),
          ),
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening gallery: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFFC4A06E)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Opening gallery...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF8B7355),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFAF1E6), Color(0xFFF5E6D3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
