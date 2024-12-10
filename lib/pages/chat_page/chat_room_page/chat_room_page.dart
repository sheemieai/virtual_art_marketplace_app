import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatRoomPage extends StatefulWidget {
  final String chatRoomName;

  const ChatRoomPage({Key? key, required this.chatRoomName}) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  List<String> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  // Send Message method
  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      setState(() {
        final now = DateTime.now();
        final formattedTime = _formatTime(now);
        _messages.add("$messageText\n$formattedTime");
      });
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatRoomName),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            // title
            Text(
              "Welcome to ${widget.chatRoomName}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            // Expanded widget for the messages
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final reversedIndex = _messages.length - 1 - index;
                  final message = _messages[reversedIndex];

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // A row with a text field and a send button
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Colors.deepPurple,
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
