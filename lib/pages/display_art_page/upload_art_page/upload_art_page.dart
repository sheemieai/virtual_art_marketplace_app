import 'package:flutter/material.dart';

class UploadArtPage extends StatelessWidget {
  const UploadArtPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple,
      child: const Center(
        child: Text(
          "Upload Art Page",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}