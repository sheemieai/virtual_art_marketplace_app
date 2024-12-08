import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
      ChatsPage(), // 1
      ChatRoomPage(chatRoomName: '',), // 2
      UploadArtPage(), // 3
      DisplayArtPage(), // 4
      FavoriteArtPage(
        // fake user for testing
        loggedInUser: fakeUser,
      ), // 5
      MyArtPage(
        // fake user for testing
        loggedInUser: fakeUser,
      ), // 6
      ShoppingCartPage(), // 7
      PaymentPage(), // 8
      SettingsPage(), // 9
      MainPage(), // 10
    ];

    return MaterialApp(
      title: "J-Arib Virtual Marketplace",
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: pages[6],
    );
  }
}