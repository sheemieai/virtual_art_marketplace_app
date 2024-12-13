import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:virtual_marketplace_app/models/chat_model/chat_page_model.dart';
import 'package:virtual_marketplace_app/models/chat_model/chat_room_model.dart';
import 'package:virtual_marketplace_app/pages/chat_page/chat_page.dart';
import 'package:virtual_marketplace_app/pages/chat_page/chat_room_page/chat_room_page.dart';
import 'package:virtual_marketplace_app/pages/display_art_page/display_art_page.dart';
import 'package:virtual_marketplace_app/pages/display_art_page/upload_art_page/upload_art_page.dart';
import 'package:virtual_marketplace_app/pages/favorite_page/favorite_page.dart';
import 'package:virtual_marketplace_app/pages/main_page/main_page.dart';
import 'package:virtual_marketplace_app/pages/my_art_page/my_art_page.dart';
import 'package:virtual_marketplace_app/pages/payment_page/payment_page.dart';
import 'package:virtual_marketplace_app/pages/payment_page/shopping_cart/shopping_cart_page.dart';
import 'package:virtual_marketplace_app/pages/settings_page/settings_page.dart';
import 'db/firestore_db.dart';
import 'models/art_model/art_model.dart';
import 'models/user_model/user_model.dart';
import 'pages/login_page/login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final FirebaseDb firebaseDb = FirebaseDb();

  // Fetch the fake user with id user-999001
  final UserModel? fakeUser = await firebaseDb.getUser("user-999001");

  if (fakeUser == null) {
    print("Fake user with ID 999001 not found in Firestore. Exiting...");
    return;
  }

  runApp(MyApp(fakeUser: fakeUser));
}

class MyApp extends StatelessWidget {
  final UserModel fakeUser;

  MyApp({super.key, required this.fakeUser});

  @override
  Widget build(BuildContext context) {
    // List of pages
    final List<Widget> pages = [
      LoginPage(), // 0
      ChatsPage(loggedInUser: fakeUser), // 1
      ChatRoomPage(
          loggedInUser: fakeUser,
          passedChatPage: ChatPageModel(
              id: "id-chat",
              chatBoxId: 12345,
              chatRoomName: "testroom",
              loggedInUser: fakeUser,
              userGettingMessage: fakeUser,
              userGettingMessageIconUri: "",
              lastMessageSent: "test_lastMessageSent",
              lastMessageDate: DateTime.now())), // 2
      UploadArtPage(
        loggedInUser: fakeUser,
      ), // 3
      DisplayArtPage(
        // fake art model
        passedArtModel: ArtModel(
          id: 'art1',
          artId: 101,
          artWorkPictureUri: '...',
          artWorkName: 'Starry Night',
          artWorkCreator: UserModel(
            id: 'user1',
            userId: 1,
            userEmail: 'artist@example.com',
            userName: 'Vincent van Gogh',
            userMoney: '5000',
            userPictureUri: 'lib/img/user/photos/artist.jpg',
            registrationDatetime: DateTime.now(),
          ),
          artDimensions: '50x60cm',
          artPrice: '1000',
          artType: 'Painting',
          artFavoriteStatusUserList: [],
        ),
        loggedInUser: fakeUser,
      ), // 4
      FavoriteArtPage(
        // fake user for testing
        loggedInUser: fakeUser,
      ), // 5
      MyArtPage(
        // fake user for testing
        loggedInUser: fakeUser,
      ), // 6
      ShoppingCartPage(
        loggedInUser: fakeUser,
      ), // 7
      PaymentPage(
        loggedInUser: fakeUser,
      ), // 8
      SettingsPage(
        loggedInUser: fakeUser,
      ), // 9
      MainPage(
        loggedInUser: fakeUser,
      ), // 10
    ];

    return MaterialApp(
      title: "J-Arib Virtual Marketplace",
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: pages[0],
    );
  }
}
