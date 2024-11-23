import 'package:flutter/material.dart';

class DisplayArtPage extends StatelessWidget {
  const DisplayArtPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepPurple,
      child: const Center(
        child: Text(
          "Display Art Page",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}