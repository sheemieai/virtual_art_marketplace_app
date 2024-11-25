import 'package:flutter/material.dart';
import 'package:virtual_marketplace_app/pages/chat_page/chat_room_page/chat_room_page.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  // List to hold chat rooms dynamically
  final List<String> chatRooms = [];

  // Function to add a new chat room
  void _addChatRoom() {
    setState(() {
      if (chatRooms.length < 40) {
        int newChatNumber = chatRooms.length + 1;
        chatRooms.add("Chat Room $newChatNumber");
      } else {
        // Limits number of chats to 40
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You can only add up to 40 chats!"),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        backgroundColor: const Color(0xFFFAF3E0),
      ),
      body: chatRooms.isEmpty
          ?
          // Default text when there is not chat rooms
          const Center(
              child: Text(
                "No chats available. Start a new chat!",
                style: TextStyle(color: Color(0xFF5A3D2B), fontSize: 30),
              ),
            )
          : ListView.builder(
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Navigate to the respective ChatRoomPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoomPage(
                          chatRoomName: chatRooms[index],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: const Color(0xFF5A3D2B),
                    child: ListTile(
                      title: Text(
                        chatRooms[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        "Tap to open chat",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                );
              },
            ),
      backgroundColor: const Color(0xFFFAF3E0),
      // button to add chat room
      floatingActionButton: FloatingActionButton(
        onPressed: _addChatRoom,
        backgroundColor: const Color(0xFF5A3D2B),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
