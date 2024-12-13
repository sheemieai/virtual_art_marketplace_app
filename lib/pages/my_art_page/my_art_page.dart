import 'dart:math';
import 'package:flutter/material.dart';
import 'package:virtual_marketplace_app/db/firestore_db.dart';
import 'package:virtual_marketplace_app/models/user_model/user_model.dart';
import 'package:virtual_marketplace_app/models/art_model/art_model.dart';
import 'package:virtual_marketplace_app/pages/chat_page/chat_page.dart';
import 'package:virtual_marketplace_app/pages/display_art_page/upload_art_page/upload_art_page.dart';
import 'package:virtual_marketplace_app/pages/favorite_page/favorite_page.dart';
import 'package:virtual_marketplace_app/pages/login_page/login_page.dart';
import 'package:virtual_marketplace_app/pages/main_page/main_page.dart';
import 'package:virtual_marketplace_app/pages/payment_page/shopping_cart/shopping_cart_page.dart';
import '../display_art_page/display_art_page.dart';
import '../settings_page/settings_page.dart';

class MyArtPage extends StatefulWidget {
  final UserModel loggedInUser;

  const MyArtPage({super.key, required this.loggedInUser});

  @override
  State<MyArtPage> createState() => MyArtPageState();
}

class MyArtPageState extends State<MyArtPage> {
  final FirebaseDb firestoreDb = FirebaseDb();
  List<ArtModel> artModels = [];
  ArtModel? randomArtModel;
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();

    fetchArtData();
  }

  Future<void> fetchArtData() async {
    try {
      //final apiKey = await firestoreDb.fetchPixabayApiKey();
      //final fetchedArtModels = await ArtModel.fetchArtModelsFromPixabay(apiKey);
      final int userId = widget.loggedInUser.userId;
      final List<ArtModel> fetchedArtModels =
          await firestoreDb.getAllArtsByUserId(userId);

      setState(() {
        artModels = fetchedArtModels;
        if (artModels.isNotEmpty) {
          randomArtModel = artModels[Random().nextInt(artModels.length)];
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Art"),
        centerTitle: true,
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
                      builder: (context) => MainPage(
                            loggedInUser: widget.loggedInUser,
                          )),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text("Favorites"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FavoriteArtPage(
                            loggedInUser: widget.loggedInUser,
                          )),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16.0),
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          image: randomArtModel != null
                              ? DecorationImage(
                                  image: AssetImage(
                                    randomArtModel!.artWorkPictureUri,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: randomArtModel == null
                            ? const Center(
                                child: Text(
                                  "No Picture Uploaded",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black54,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        "Welcome, ${widget.loggedInUser.userName}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: artModels.length,
                          itemBuilder: (context, index) {
                            final artModel = artModels[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DisplayArtPage(
                                      passedArtModel: artModel,
                                      loggedInUser: widget.loggedInUser,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8.0),
                                  image: DecorationImage(
                                    image:
                                        AssetImage(artModel.artWorkPictureUri),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
