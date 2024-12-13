import 'dart:math';
import 'package:flutter/material.dart';
import 'package:virtual_marketplace_app/db/firestore_db.dart';
import 'package:virtual_marketplace_app/models/art_model/art_model.dart';
import 'package:virtual_marketplace_app/models/user_model/user_model.dart';
import 'package:virtual_marketplace_app/pages/favorite_page/favorite_page.dart';
import 'package:virtual_marketplace_app/pages/my_art_page/my_art_page.dart';
import '../chat_page/chat_page.dart';
import '../display_art_page/display_art_page.dart';
import '../display_art_page/upload_art_page/upload_art_page.dart';
import '../login_page/login_page.dart';
import '../payment_page/shopping_cart/shopping_cart_page.dart';
import '../settings_page/settings_page.dart';

class MainPage extends StatefulWidget {
  final UserModel loggedInUser;

  const MainPage({super.key, required this.loggedInUser});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final FirebaseDb firestoreDb = FirebaseDb();
  List<ArtModel> artModels = [];
  ArtModel? randomArtModel;
  Map<String, List<ArtModel>> categorizedArt = {};
  bool isLoading = true;
  String errorMessage = "";

  final List<String> artTypes = [
    "Photo",
    "Painting",
    "Photography",
    "Sculpture",
    "Digital"
  ];

  @override
  void initState() {
    super.initState();
    fetchArtData();
  }

  Future<void> fetchArtData() async {
    try {
      //final apiKey = await firestoreDb.fetchPixabayApiKey();
      //final fetchedArtModels = await ArtModel.fetchArtModelsFromPixabay(apiKey);
      final fetchedArtModels = await firestoreDb.getAllArts();
      setState(() {
        artModels = fetchedArtModels;
        randomArtModel = artModels.isNotEmpty
            ? artModels[Random().nextInt(artModels.length)]
            : null;
        categorizeArtByType();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void categorizeArtByType() {
    for (var artType in artTypes) {
      final List<ArtModel> filteredArt = artModels
          .where((art) => art.artType == artType)
          .toList();

      filteredArt.shuffle();

      categorizedArt[artType] = filteredArt.take(15).toList();
    }
  }

  Future<void> toggleFavorite(ArtModel artModel) async {
    final userId = widget.loggedInUser.userId;

    setState(() {
      if (artModel.artFavoriteStatusUserList.contains(userId)) {
        artModel.artFavoriteStatusUserList.remove(userId);
      } else {
        artModel.artFavoriteStatusUserList.add(userId);
      }
    });

    try {
      await firestoreDb.updateFavoriteArt(artModel);
      print("Favorite status updated for art: ${artModel.id}");
    } catch (e) {
      print("Error updating favorite status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
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
              leading: const Icon(Icons.favorite),
              title: const Text("Favorite"),
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
              leading: Icon(Icons.palette),
              title: Text("My Art"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyArtPage(
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
                Navigator.push(
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
                  child: ListView(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(8.0),
                          image: randomArtModel != null
                              ? DecorationImage(
                                  image: AssetImage(
                                      randomArtModel!.artWorkPictureUri),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: randomArtModel == null
                            ? const Center(
                                child: Text(
                                  "No Picture Available",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black54,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 24.0),
                      ...artTypes
                          .map((artType) => buildArtTypeSection(artType))
                          .toList(),
                    ],
                  ),
                ),
    );
  }

  Widget buildArtTypeSection(final String artType) {
    final artList = categorizedArt[artType] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          artType,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: artList.length,
            itemBuilder: (context, index) {
              final artModel = artList[index];
              final isFavorited = artModel.artFavoriteStatusUserList
                  .contains(widget.loggedInUser.userId);
              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: GestureDetector(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: AssetImage(artModel.artWorkPictureUri),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            artModel.artPrice,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            onPressed: () => toggleFavorite(artModel),
                            icon: Icon(
                              Icons.favorite,
                              color: isFavorited ? Colors.red : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
