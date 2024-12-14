import 'package:flutter/material.dart';
import 'package:virtual_marketplace_app/models/cart_model/cart_model.dart';
import 'package:virtual_marketplace_app/pages/chat_page/chat_page.dart';
import '../../../db/firestore_db.dart';
import '../../../helper/currency/currency_helper.dart';
import '../../../helper/currency/exchange_rate_helper.dart';
import '../../../models/art_model/art_model.dart';
import '../../../models/payment_model/purchase_art_model.dart';
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
  List<PurchaseArtModel> purchasedArtList = [];
  int subtotal = 0;
  bool isLoading = true;
  final Map<String, double> exchangeRates = ExchangeRateHelper().exchangeRates;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
    fetchPurchasedItems();
  }

  Future<void> fetchPurchasedItems() async {
    try {
      final List<PurchaseArtModel> purchases =
        await firestoreDb.getAllPurchasesByBuyerId(widget.loggedInUser.userId);

      setState(() {
        purchasedArtList = purchases.take(5).toList();
      });
    } catch (e) {
      print("Error fetching purchased items: $e");
    }
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
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                if (cartArtList.isEmpty)
                  const Center(child: Text("Your cart is empty."))
                else
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: cartArtList.length,
                        itemBuilder: (context, index) {
                          final item = cartArtList[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                            style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(
                                          "${CurrencyHelper.convert(
                                            double.tryParse(item.artPrice.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0,
                                            widget.loggedInUser.preferredCurrency ?? "USD",
                                            exchangeRates,
                                          ).toStringAsFixed(2)} ${widget.loggedInUser.preferredCurrency}",
                                        ),
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
                  ),
                buildPurchasedItemsSection(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Subtotal: ${CurrencyHelper.convert(
                    subtotal.toDouble(),
                    widget.loggedInUser.preferredCurrency ?? "USD",
                    exchangeRates,
                  ).toStringAsFixed(2)} ${widget.loggedInUser.preferredCurrency}",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                ),
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

  Widget buildPurchasedItemsSection() {
    // Hide widget if no items
    if (purchasedArtList.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "Recently Purchased Items",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: purchasedArtList.length,
            itemBuilder: (context, index) {
              final purchasedItem = purchasedArtList[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: AssetImage(purchasedItem.artModel.artWorkPictureUri),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      purchasedItem.artModel.artWorkName,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
