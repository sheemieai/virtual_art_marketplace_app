import 'package:flutter/material.dart';
import 'package:virtual_marketplace_app/db/firestore_db.dart';
import 'package:virtual_marketplace_app/models/chat_model/chat_page_model.dart';
import 'package:virtual_marketplace_app/models/user_model/user_model.dart';
import 'package:virtual_marketplace_app/pages/chat_page/chat_room_page/chat_room_page.dart';

class ChatsPage extends StatefulWidget {
  final UserModel loggedInUser;

  const ChatsPage({Key? key, required this.loggedInUser}) : super(key: key);

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  List<ChatPageModel> chatRooms = [];
  final FirebaseDb firebaseDb = FirebaseDb();
  Map<String, UserModel> userCache = {};

  // Fetch user with caching
  Future<UserModel?> fetchUser(String userId) async {
    if (userCache.containsKey(userId)) {
      return userCache[userId];
    }
    final user = await firebaseDb.getUser(userId);
    if (user != null) {
      userCache[userId] = user;
    }
    return user;
  }

  // Function to add a new chat room
  Future<void> _addChatRoom(String recipientUserId) async {
    try {
      // Fetch recipient user details
      final recipientUser = await fetchUser(recipientUserId);
      if (recipientUser == null) {
        throw Exception("Recipient user not found");
      }

      int newChatNumber = chatRooms.length + 1;
      String newChatName = "Chat Room $newChatNumber";

      // Create a new ChatPageModel
      final newChatPage = ChatPageModel(
        id: "",
        chatBoxId: newChatNumber,
        chatRoomName: newChatName,
        loggedInUser: widget.loggedInUser,
        userGettingMessage: recipientUser,
        userGettingMessageIconUri: recipientUser.userPictureUri,
        lastMessageSent: "",
        lastMessageDate: DateTime.now(),
      );

      // Save to Firestore
      await firebaseDb.addChatPage(newChatPage);

      // Update local chat room list
      setState(() {
        chatRooms.add(newChatPage);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$newChatName added successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add chat room: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        backgroundColor: const Color(0xFFFAF3E0),
      ),
      body: chatRooms.isEmpty
          ? const Center(
              child: Text(
                "No chats available. Start a new chat!",
                style: TextStyle(color: Color(0xFF5A3D2B), fontSize: 30),
              ),
            )
          : ListView.builder(
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoom = chatRooms[index];

                return FutureBuilder<UserModel?>(
                  future:
                      fetchUser(chatRoom.userGettingMessage.userId.toString()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data == null) {
                      return ListTile(
                        title: Text(chatRoom.chatRoomName),
                        subtitle: const Text("User not found"),
                      );
                    }

                    final recipientUser = snapshot.data!;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatRoomPage(
                              chatRoomName: chatRoom.chatRoomName,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        color: const Color(0xFF5A3D2B),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(recipientUser.userPictureUri),
                          ),
                          title: Text(
                            chatRoom.chatRoomName,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "Chat with ${recipientUser.userName}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      backgroundColor: const Color(0xFFFAF3E0),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _addChatRoom('testRecipientUserId');
        },
        backgroundColor: const Color(0xFF5A3D2B),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
