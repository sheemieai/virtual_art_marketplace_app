import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:virtual_marketplace_app/db/firestore_db.dart';
import 'package:virtual_marketplace_app/helper/fake/fake_user_creator_helper.dart';
import 'package:virtual_marketplace_app/models/chat_model/chat_page_model.dart';
import 'package:virtual_marketplace_app/models/user_model/user_model.dart';
import 'package:virtual_marketplace_app/pages/chat_page/chat_room_page/chat_room_page.dart';
import 'package:virtual_marketplace_app/pages/display_art_page/upload_art_page/upload_art_page.dart';
import 'package:virtual_marketplace_app/pages/favorite_page/favorite_page.dart';
import 'package:virtual_marketplace_app/pages/login_page/login_page.dart';
import 'package:virtual_marketplace_app/pages/main_page/main_page.dart';
import 'package:virtual_marketplace_app/pages/my_art_page/my_art_page.dart';
import 'package:virtual_marketplace_app/pages/payment_page/shopping_cart/shopping_cart_page.dart';
import 'package:virtual_marketplace_app/pages/settings_page/settings_page.dart';

class ChatsPage extends StatefulWidget {
  final UserModel loggedInUser;

  const ChatsPage({Key? key, required this.loggedInUser}) : super(key: key);

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  List<ChatPageModel> chatRooms = [];
  final FirebaseDb firebaseDb = FirebaseDb();
  UserModel? selectedUser;
  ChatPageModel? selectedChatPage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
    _startAutoRefresh();
  }

  // Function to start the auto-refresh
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      _loadChatRooms();
    });
  }

  Future<void> _loadChatRooms() async {
    try {
      final List<ChatPageModel> fetchedChatRooms =
          await firebaseDb.getAllChatPagesByUserId(widget.loggedInUser.userId);
      setState(() {
        chatRooms = fetchedChatRooms;
      });
    } catch (e) {
      print("Error fetching chat rooms: $e");
    }
  }

  Future<void> _pickUser() async {
    try {
      final List<UserModel> users = await firebaseDb.getAllUsers();

      if (users.isEmpty) {
        print("No users found in the database.");
        return;
      }

      final UserModel? chosenUser = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Select a User'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(users[index].userName),
                    onTap: () {
                      Navigator.pop(context, users[index]);
                    },
                  );
                },
              ),
            ),
          );
        },
      );

      if (chosenUser != null) {
        setState(() {
          selectedUser = chosenUser;
        });

        print("Selected user: ${selectedUser!.userName}");
        await createChatPageModel();
      }
    } catch (e) {
      print("Error fetching users for selection: $e");
    }
  }

  Future<void> createChatPageModel() async {
    try {
      String chatRoomName = "Chat with ${selectedUser!.userName} & ${widget.loggedInUser.userName}";

      if (selectedUser!.userName == widget.loggedInUser.userName) {
        chatRoomName = "Chat with me";
      }

      final int randInt = getRandomInteger();

      final chatPageModel = ChatPageModel(
        id: getRandomLettersAndDigits(),
        chatBoxId: randInt,
        chatRoomName: chatRoomName,
        loggedInUser: widget.loggedInUser,
        userGettingMessage: selectedUser!,
        userGettingMessageIconUri: selectedUser!.userPictureUri,
        lastMessageSent: "",
        lastMessageDate: DateTime.now(),
      );

      if (selectedUser!.userName != widget.loggedInUser.userName) {
        final recipientChatPageModel = ChatPageModel(
          id: getRandomLettersAndDigits(),
          chatBoxId: randInt,
          chatRoomName: chatRoomName,
          loggedInUser: selectedUser!,
          userGettingMessage: widget.loggedInUser,
          userGettingMessageIconUri: widget.loggedInUser.userPictureUri,
          lastMessageSent: "",
          lastMessageDate: DateTime.now(),
        );

        await firebaseDb.addChatPage(recipientChatPageModel);
      }

      await firebaseDb.addChatPage(chatPageModel);

      setState(() {
        chatRooms.add(chatPageModel);
      });
    } catch (e) {
      print("Error creating new chat room: $e");
    }
  }

  String getRandomLettersAndDigits() {
    const characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(
        6, (_) => characters[random.nextInt(characters.length)]).join();
  }

  int getRandomInteger() {
    final random = Random();
    return int.parse(
        List.generate(6, (_) => random.nextInt(10).toString()).join());
  }

  void goToChatRoom() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomPage(
            loggedInUser: widget.loggedInUser,
            passedChatPage: selectedChatPage!),
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: chatRooms.isEmpty
          ? const Center(
              child: Text(
                "No chats available. Start a new chat!",
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            )
          : ListView.builder(
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoom = chatRooms[index];

                return GestureDetector(
                  onTap: () {
                    selectedChatPage = chatRooms[index];
                    goToChatRoom();
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.black, Colors.deepPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(
                            chatRoom.userGettingMessageIconUri,
                          ),
                          radius: 30,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chatRoom.chatRoomName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                FakeUserCreatorHelper.capitalize(
                                    chatRoom.lastMessageSent),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      backgroundColor: Colors.white,
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          await _pickUser();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add),
            SizedBox(width: 8),
            Text("New Chat"),
          ],
        ),
      ),
    );
  }
}
