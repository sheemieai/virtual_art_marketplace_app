import 'package:flutter/material.dart';
import 'package:virtual_marketplace_app/models/cart_model/cart_model.dart';
import 'package:virtual_marketplace_app/pages/chat_page/chat_page.dart';
import '../../../db/firestore_db.dart';
import '../../../models/art_model/art_model.dart';
import '../../../models/user_model/user_model.dart';
import '../../display_art_page/upload_art_page/upload_art_page.dart';
import '../../favorite_page/favorite_page.dart';
import '../../login_page/login_page.dart';
import '../../main_page/main_page.dart';
import '../../my_art_page/my_art_page.dart';
import '../../settings_page/settings_page.dart';
import '../payment_page.dart';

class ShoppingCartPage extends StatefulWidget {
  final UserModel loggedInUser;

  const ShoppingCartPage({Key? key, required this.loggedInUser})
      : super(key: key);
  @override
  ShoppingCartPageState createState() => ShoppingCartPageState();
}

class ShoppingCartPageState extends State<ShoppingCartPage> {
  final FirebaseDb firestoreDb = FirebaseDb();
  List<ArtModel> cartArtList = [];
  int subtotal = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    try {
      final List<CartModel> dbCartItems =
          await firestoreDb.getAllCartsByUserId(widget.loggedInUser.userId);
      if (dbCartItems.isNotEmpty) {
        final cartList = dbCartItems.first;
        setState(() {
          cartArtList = cartList.artModelList;
          subtotal = calculateSubtotal();
          isLoading = false;
        });
      } else {
        setState(() {
          cartArtList = [];
          subtotal = 0;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching cart items: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load cart items.")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  int calculateSubtotal() {
    return cartArtList.fold(0, (sum, item) {
      try {
        final priceString = item.artPrice.replaceAll('\$', '');
        final price = int.parse(priceString);
        return sum + price;
      } catch (e) {
        print("Error parsing price: ${item.artPrice}, Error: $e");
        return sum;
      }
    });
  }

  Future<void> removeItemFromCart(final int artIndex) async {
    try {
      final List<CartModel> dbCartItems =
          await firestoreDb.getAllCartsByUserId(widget.loggedInUser.userId);

      if (dbCartItems.isNotEmpty) {
        final CartModel cartList = dbCartItems.first;

        List<ArtModel> updatedArtList = List.from(cartList.artModelList);
        updatedArtList.removeAt(artIndex);

        final updatedCartList = cartList.copyWith(artModelList: updatedArtList);

        await firestoreDb.updateCart(updatedCartList);

        if (updatedArtList.isEmpty) {
          await firestoreDb.updateCart(cartList.copyWith(artModelList: []));

          setState(() {
            cartArtList = [];
            subtotal = 0;
          });

          await firestoreDb.deleteCart(cartList);
          print("Cart cleared.");
          return;
        }

        final List<CartModel> refreshedCartItems =
            await firestoreDb.getAllCartsByUserId(widget.loggedInUser.userId);

        setState(() {
          cartArtList = refreshedCartItems.isNotEmpty
              ? refreshedCartItems.first.artModelList
              : [];
          subtotal = calculateSubtotal();
        });

        print("Cart updated in UI.");
      } else {
        print("No cart items found for user: ${widget.loggedInUser.userId}");
        setState(() {
          cartArtList = [];
          subtotal = 0;
        });
      }
    } catch (e) {
      print("Error removing item from cart: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to remove item.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping Cart"),
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
      body: Column(
        children: [
          Expanded(
            child: cartArtList.isEmpty
                ? const Center(child: Text("Your cart is empty."))
                : ListView.builder(
                    itemCount: cartArtList.length,
                    itemBuilder: (context, index) {
                      final item = cartArtList[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8.0),
                                  image: DecorationImage(
                                    image: AssetImage(item.artWorkPictureUri),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.artWorkName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(item.artPrice),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  removeItemFromCart(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Subtotal: \$${subtotal.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: cartArtList.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                loggedInUser: widget.loggedInUser,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart),
                      SizedBox(width: 8),
                      Text("Checkout"),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
