import 'package:flutter/material.dart';
import 'package:virtual_marketplace_app/models/art_model/art_model.dart';
import 'package:virtual_marketplace_app/models/payment_model/purchase_art_model.dart';
import 'package:virtual_marketplace_app/models/user_model/user_model.dart';
import 'package:virtual_marketplace_app/pages/payment_page/shopping_cart/shopping_cart_page.dart';
import 'package:virtual_marketplace_app/db/firestore_db.dart';

class PaymentPage extends StatefulWidget {
  final UserModel loggedInUser;

  const PaymentPage({Key? key, required this.loggedInUser}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final FirebaseDb firebaseDb = FirebaseDb();

  double currentBalance = 0;
  final TextEditingController expiryDateController = TextEditingController();
  UserModel? currentUser;
  List<ArtModel> userArts = [];

  @override
  void initState() {
    super.initState();
    _initializeUserBalance();
    _fetchUserArts();
    calculateTotalPrice();
  }

  // Fetch the current user money balance
  Future<void> _initializeUserBalance() async {
    setState(() {
      currentBalance = widget.loggedInUser.userMoney as double;
    });
  }

  // Fetch the current user art models
  Future<void> _fetchUserArts() async {
    try {
      List<ArtModel> arts =
          await firebaseDb.getAllArtsByUserId(widget.loggedInUser.userId);
      setState(() {
        userArts = arts;
      });
    } catch (e) {
      print("Error fetching user arts: $e");
    }
  }

  @override
  void dispose() {
    expiryDateController.dispose();
    super.dispose();
  }

  // Fetch the total price of art models
  double calculateTotalPrice() {
    return userArts.fold(
      0,
      (sum, item) =>
          sum +
          (double.tryParse(item.artPrice.replaceAll(RegExp(r'[^\d.]'), '')) ??
              0),
    );
  }

  // add funds to current balance
  void addFunds() {
    setState(() {
      currentBalance += 20;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funds Added Successfully!'),
      ),
    );
  }

  void makePayment(double totalPrice) async {
    if (currentBalance >= totalPrice) {
      try {
        setState(() {
          currentBalance -= totalPrice;
        });

        // Process each art item in the user's cart
        for (ArtModel art in userArts) {
          // Create a PurchaseArtModel for the current item
          final purchaseArt = PurchaseArtModel(
            id: "",
            artModel: art,
            artWorkPurchaseDate: DateTime.now(),
          );

          // Add the purchase record to Firestore
          await firebaseDb.addPurchaseArt(purchaseArt);
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment Successful!'),
          ),
        );
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process payment: $e'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient Balance! Add Funds.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = calculateTotalPrice();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Purchase Page"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[300]!, width: 2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ShoppingCartPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Total Section
                Center(
                  child: Text(
                    'Total: \$${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Divider(height: 30, thickness: 1),
                // Item Details Section
                const Text(
                  'Item Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                ...userArts.map((artItem) => Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[100],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: ${artItem.artWorkName}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Price: ${artItem.artPrice}'),
                          Text('Dimensions: ${artItem.artDimensions}'),
                          Text('Type: ${artItem.artType}'),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                // Current Balance Section
                const Text(
                  'Current Balance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: Text(
                    '\$${currentBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Divider(height: 30, thickness: 1),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: addFunds,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        'Add Funds',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => makePayment(totalPrice),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        'Make Payment',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
