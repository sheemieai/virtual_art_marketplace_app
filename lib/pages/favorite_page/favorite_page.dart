import 'dart:math';
import 'package:flutter/material.dart';
import 'package:virtual_marketplace_app/db/firestore_db.dart';
import 'package:virtual_marketplace_app/models/art_model/art_model.dart';
import 'package:virtual_marketplace_app/models/user_model/user_model.dart';
import 'package:virtual_marketplace_app/pages/chat_page/chat_page.dart';
import 'package:virtual_marketplace_app/pages/display_art_page/upload_art_page/upload_art_page.dart';
import 'package:virtual_marketplace_app/pages/login_page/login_page.dart';
import 'package:virtual_marketplace_app/pages/main_page/main_page.dart';
import 'package:virtual_marketplace_app/pages/my_art_page/my_art_page.dart';
import 'package:virtual_marketplace_app/pages/payment_page/shopping_cart/shopping_cart_page.dart';
import '../../helper/currency/currency_helper.dart';
import '../../helper/currency/exchange_rate_helper.dart';
import '../../models/cart_model/cart_model.dart';
import '../display_art_page/display_art_page.dart';
import '../settings_page/settings_page.dart';

class FavoriteArtPage extends StatefulWidget {
  final UserModel loggedInUser;

  const FavoriteArtPage({super.key, required this.loggedInUser});

  @override
  State<FavoriteArtPage> createState() => FavoriteArtPageState();
}

class FavoriteArtPageState extends State<FavoriteArtPage> {
  final FirebaseDb firebaseDb = FirebaseDb();
  List<ArtModel> favoriteArtModels = [];
  List<ArtModel> filteredArtModels = [];
  bool isLoading = true;
  String errorMessage = "";
  String searchQuery = "";
  final Map<String, double> exchangeRates = ExchangeRateHelper().exchangeRates;

  @override
  void initState() {
    super.initState();
    fetchFavoriteArtData();
  }

  Future<void> fetchFavoriteArtData() async {
    try {
      //final apiKey = await firebaseDb.fetchPixabayApiKey();
      //final fetchedArtModels = await ArtModel.fetchArtModelsFromPixabay(apiKey);
      final int userId = widget.loggedInUser.userId;
      final List<ArtModel> fetchedArtModels =
          await firebaseDb.getAllFavoriteArtsByUserId(userId);

      setState(() {
        favoriteArtModels = fetchedArtModels;
        filteredArtModels = fetchedArtModels;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void filterArtModels(final String query) {
    setState(() {
      searchQuery = query;
      filteredArtModels = favoriteArtModels
          .where((artModel) =>
              artModel.artWorkName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> toggleFavorite(final ArtModel artModel) async {
    final userId = widget.loggedInUser.userId;

    setState(() {
      if (artModel.artFavoriteStatusUserList.contains(userId)) {
        artModel.artFavoriteStatusUserList.remove(userId);
      } else {
        artModel.artFavoriteStatusUserList.add(userId);
      }
    });

    try {
      await firebaseDb.updateFavoriteArt(artModel);
      print("Favorite status updated for art: ${artModel.id}");
    } catch (e) {
      print("Error updating favorite status: $e");
    }
  }

  Future<void> buyArt(final ArtModel artModel) async {
    final List<ArtModel> oldArtModelList =
    await firebaseDb.getAllArtModelsByUserId(widget.loggedInUser.userId);

    try {
      if (oldArtModelList.isEmpty) {
        oldArtModelList.add(artModel);

        final CartModel newCartModel = CartModel(
          id: getRandomLettersAndDigits(),
          user: widget.loggedInUser,
          artModelList: oldArtModelList,
        );

        await firebaseDb.addCart(newCartModel);
      } else {
        final List<CartModel> cartModelList =
        await firebaseDb.getAllCartsByUserId(widget.loggedInUser.userId);

        final CartModel oldCartModel = cartModelList.first;

        oldCartModel.artModelList.add(artModel);

        await firebaseDb.updateCart(oldCartModel);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You have successfully bought the artwork!"),
          duration: Duration(seconds: 3),
        ),
      );
      print("Successfully completed buyArt method.");
    } catch (e) {
      print("Error during _buyArt method: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to complete purchase. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorite Art"),
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
          ? const Center(child: CircularProgressIndicator())
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
                    children: [
                      TextField(
                        onChanged: filterArtModels,
                        decoration: InputDecoration(
                          labelText: "Search",
                          hintText: "Search art by name",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredArtModels.length,
                          itemBuilder: (context, index) {
                            final artModel = filteredArtModels[index];
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 200,
                                    width: double.infinity,
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
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            artModel.artWorkName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "${CurrencyHelper.convert(
                                              double.tryParse(artModel.artPrice.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0,
                                              widget.loggedInUser.preferredCurrency ?? "USD",
                                              exchangeRates,
                                            ).toStringAsFixed(2)} ${widget.loggedInUser.preferredCurrency}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              await toggleFavorite(artModel);
                                              await fetchFavoriteArtData();
                                            },
                                            icon: Icon(
                                              artModel.artFavoriteStatusUserList.contains(widget.loggedInUser.userId)
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: Colors.red,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () async {
                                              await buyArt(artModel);
                                            },
                                            icon: const Icon(
                                              Icons.shopping_cart_outlined,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 32.0),
                                ],
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
