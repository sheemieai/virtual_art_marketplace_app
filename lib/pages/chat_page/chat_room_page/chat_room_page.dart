import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:virtual_marketplace_app/db/firestore_db.dart';
import 'package:virtual_marketplace_app/helper/fake/fake_user_creator_helper.dart';
import 'package:virtual_marketplace_app/models/chat_model/chat_page_model.dart';
import 'package:virtual_marketplace_app/models/chat_model/chat_room_model.dart';
import 'package:virtual_marketplace_app/models/chat_model/message_model.dart';
import 'package:virtual_marketplace_app/models/user_model/user_model.dart';
import 'package:virtual_marketplace_app/pages/chat_page/chat_page.dart';
import 'package:virtual_marketplace_app/pages/main_page/main_page.dart';
import 'package:virtual_marketplace_app/pages/display_art_page/upload_art_page/upload_art_page.dart';
import 'package:virtual_marketplace_app/pages/favorite_page/favorite_page.dart';
import 'package:virtual_marketplace_app/pages/login_page/login_page.dart';
import 'package:virtual_marketplace_app/pages/my_art_page/my_art_page.dart';
import 'package:virtual_marketplace_app/pages/payment_page/shopping_cart/shopping_cart_page.dart';
import 'package:virtual_marketplace_app/pages/settings_page/settings_page.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel loggedInUser;
  final ChatPageModel passedChatPage;

  const ChatRoomPage(
      {Key? key, required this.loggedInUser, required this.passedChatPage})
      : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final FirebaseDb firebaseDb = FirebaseDb();
  List<Message> messagesList = [];
  final TextEditingController _messageController = TextEditingController();
  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  ChatRoomModel? _chatRoomModel;

  @override
  void initState() {
    super.initState();
    _fetchChatRoom();
  }

  // Send Message method
  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();

    if (messageText.isNotEmpty) {
      final Message newMessage = Message(
        userName: widget.loggedInUser.userName,
        messageString: messageText,
        messageId: messagesList.length + 1,
      );

      setState(() {
        messagesList.add(newMessage);
      });

      _messageController.clear();

      // Update sender's chat room
      await firebaseDb.updateChatRoom(
        _chatRoomModel!.copyWith(messageList: messagesList),
      );

      // Update recipient's chat room
      final ChatRoomModel? receipientChatRoom =
          await firebaseDb.getChatRoomByChatBoxIdAndUserId(
              _chatRoomModel!.chatBoxId,
              _chatRoomModel!.userGettingMessage.userId);

      if (receipientChatRoom != null) {
        await firebaseDb.updateChatRoom(
          receipientChatRoom.copyWith(messageList: messagesList),
        );
      }

      // Update chat pages
      final List<ChatPageModel> chatPagesList = await firebaseDb
          .getAllChatPagesByChatBoxId(widget.passedChatPage.chatBoxId);

      for (final chatPage in chatPagesList) {
        await firebaseDb.updateChatPage(
          chatPage.copyWith(lastMessageSent: messagesList.last.messageString),
        );
      }
    }
  }

  Future<void> _fetchChatRoom() async {
    final ChatRoomModel? chatRoomsDb = await firebaseDb
        .getChatRoomByChatBoxId(widget.passedChatPage.chatBoxId);

    if (chatRoomsDb == null) {
      final ChatRoomModel? newChatRoom = ChatRoomModel(
          id: getRandomLettersAndDigits(),
          chatBoxId: widget.passedChatPage.chatBoxId,
          chatRoomName: widget.passedChatPage.chatRoomName,
          loggedInUser: widget.loggedInUser,
          userGettingMessage: widget.passedChatPage.userGettingMessage,
          messageList: []);

      final ChatRoomModel? receipientChatRoom = ChatRoomModel(
          id: getRandomLettersAndDigits(),
          chatBoxId: widget.passedChatPage.chatBoxId,
          chatRoomName: widget.passedChatPage.chatRoomName,
          loggedInUser: widget.passedChatPage.userGettingMessage,
          userGettingMessage: widget.loggedInUser,
          messageList: []);

      await firebaseDb.addChatRoom(newChatRoom!);
      await firebaseDb.addChatRoom(receipientChatRoom!);

      setState(() {
        _chatRoomModel = newChatRoom;
        messagesList = newChatRoom.messageList;
      });
    } else {
      setState(() {
        _chatRoomModel = chatRoomsDb;
        messagesList = chatRoomsDb.messageList;
      });
    }
  }

  String getRandomLettersAndDigits() {
    const characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(
        6, (_) => characters[random.nextInt(characters.length)]).join();
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
        title: Text("Chatting with " +
            FakeUserCreatorHelper.capitalize(
                widget.passedChatPage.userGettingMessage.userName)),
        backgroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MainPage(loggedInUser: widget.loggedInUser),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text("Favorite"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FavoriteArtPage(loggedInUser: widget.loggedInUser),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.palette),
              title: Text("My Art"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MyArtPage(loggedInUser: widget.loggedInUser),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text("Cart"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShoppingCartPage(
                            loggedInUser: widget.loggedInUser,
                          )),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text("Chats"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatsPage(
                            loggedInUser: widget.loggedInUser,
                          )),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text("Upload Art"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UploadArtPage(
                            loggedInUser: widget.loggedInUser,
                          )),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SettingsPage(loggedInUser: widget.loggedInUser),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Log Out"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: messagesList.length,
                itemBuilder: (context, index) {
                  final reversedIndex = messagesList.length - 1 - index;
                  final message = messagesList[reversedIndex];
                  final isLoggedInUser =
                      widget.loggedInUser.userName == message.userName;

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Align(
                      alignment: isLoggedInUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isLoggedInUser
                              ? Colors.deepPurple[100]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message.messageString,
                          style: TextStyle(
                            color:
                                isLoggedInUser ? Colors.black : Colors.black87,
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
                      onPressed: () async {
                        await _sendMessage();
                      },
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
