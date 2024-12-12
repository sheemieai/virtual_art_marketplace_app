import 'dart:math';
import 'package:flutter/material.dart';
import 'package:virtual_marketplace_app/db/firestore_db.dart';
import 'package:virtual_marketplace_app/models/art_model/art_model.dart';
import 'package:virtual_marketplace_app/models/user_model/user_model.dart';
import 'package:virtual_marketplace_app/pages/chat_page/chat_page.dart';
import 'package:virtual_marketplace_app/pages/favorite_page/favorite_page.dart';
import 'package:virtual_marketplace_app/pages/login_page/login_page.dart';
import 'package:virtual_marketplace_app/pages/main_page/main_page.dart';
import 'package:virtual_marketplace_app/pages/my_art_page/my_art_page.dart';
import 'package:virtual_marketplace_app/pages/payment_page/shopping_cart/shopping_cart_page.dart';

import '../../settings_page/settings_page.dart';

class UploadArtPage extends StatefulWidget {
  final UserModel loggedInUser;
  UploadArtPage({super.key, required this.loggedInUser});

  @override
  _UploadArtPageState createState() => _UploadArtPageState();
}

class _UploadArtPageState extends State<UploadArtPage> {
  final FirebaseDb firebaseDb = FirebaseDb();
  String? selectedImage;
  String selectedArtType = "photo";

  final TextEditingController artworkNameController = TextEditingController();
  final TextEditingController artistNameController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  void dispose() {
    artworkNameController.dispose();
    artistNameController.dispose();
    widthController.dispose();
    heightController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final images =
        List.generate(100, (index) => 'lib/img/photos/pixabayImage$index.jpg');
    final String? chosenImage = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select an Image'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, images[index]);
                  },
                  child: Image.asset(
                    images[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (chosenImage != null) {
      setState(() {
        selectedImage = chosenImage;
      });
    }
  }

  Future<void> _submitImage() async {
    if (selectedImage == null ||
        artworkNameController.text.isEmpty ||
        artistNameController.text.isEmpty ||
        widthController.text.isEmpty ||
        heightController.text.isEmpty ||
        priceController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('All fields are required'),
          );
        },
      );
      return;
    }

    final UserModel? fakeUser = await firebaseDb.getUser("user-999001");
    if (fakeUser == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('User not found'),
          );
        },
      );
      return;
    }

    final ArtModel model = ArtModel(
      id: "art-${fakeUser.userId}-${getRandomLettersAndDigits()}",
      artId: getRandomInteger(),
      artWorkPictureUri: selectedImage!,
      artWorkName: artworkNameController.text,
      artWorkCreator: fakeUser,
      artDimensions: "${widthController.text}x${heightController.text}",
      artPrice: "\$${priceController.text}",
      artType: selectedArtType,
      artFavoriteStatusUserList: [],
    );

    print('Artwork successfully submitted: ${model.toString()}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Artwork successfully submitted!'),
      ),
    );

    await firebaseDb.addArt(model);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainPage(loggedInUser: widget.loggedInUser),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Upload Artwork"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
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
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display selected artwork
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                    image: selectedImage != null
                        ? DecorationImage(
                            image: AssetImage(selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: selectedImage == null
                      ? const Center(
                          child: Text(
                            'No Artwork Selected',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                // Upload image button
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Select Art Picture"),
                ),
                const SizedBox(height: 16),
                // Artwork Name input
                TextField(
                  controller: artworkNameController,
                  decoration: const InputDecoration(
                    labelText: 'Artwork Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Artist Name input
                TextField(
                  controller: artistNameController,
                  decoration: const InputDecoration(
                    labelText: 'Artist Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Dimensions input with units
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widthController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Width (cm)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Height (cm)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Price input
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Art Price',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Art Type dropdown
                DropdownButtonFormField<String>(
                  value: selectedArtType,
                  decoration: const InputDecoration(
                    labelText: 'Art Type',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    "photo",
                    "painting",
                    "photography",
                    "sculpture",
                    "digital"
                  ]
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedArtType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Submit button
                ElevatedButton(
                  onPressed: _submitImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
