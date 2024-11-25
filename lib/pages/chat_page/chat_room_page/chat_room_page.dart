import 'package:flutter/material.dart';

class ChatRoomPage extends StatelessWidget {
  final String chatRoomName;

  const ChatRoomPage({super.key, required this.chatRoomName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chatRoomName),
        backgroundColor: Colors.blue[50],
      ),
      body: Container(
        color: Colors.blue[50],
        child: Center(
          child: Text(
            "Welcome to $chatRoomName",
            style: const TextStyle(
              fontSize: 24,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
