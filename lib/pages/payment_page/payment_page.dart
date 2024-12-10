import 'package:flutter/material.dart';
import 'package:virtual_marketplace_app/models/art_model/art_model.dart';
import 'package:virtual_marketplace_app/pages/payment_page/shopping_cart/shopping_cart_page.dart';

class PaymentPage extends StatefulWidget {
  final List<ArtModel> artItems;

  const PaymentPage({Key? key, required this.artItems}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  double currentBalance = 20;
  final TextEditingController expiryDateController = TextEditingController();

  @override
  void dispose() {
    expiryDateController.dispose();
    super.dispose();
  }

  double calculateTotalPrice() {
    return widget.artItems.fold(
      0,
      (sum, item) =>
          sum +
          double.tryParse(item.artPrice.replaceAll(RegExp(r'[^\d.]'), ''))!,
    );
  }

  void addFunds() {
    setState(() {
      currentBalance += 20; // Example: Add $20
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funds Added Successfully!'),
      ),
    );
  }

  void makePayment(double totalPrice) {
    if (currentBalance >= totalPrice) {
      setState(() {
        currentBalance -= totalPrice;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment Successful!'),
        ),
      );
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
    double totalPrice = calculateTotalPrice(); // Get the total price

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
                // // Back Button
                // IconButton(
                //   icon: const Icon(Icons.arrow_back),
                //   onPressed: () {
                //     Navigator.pushReplacement(
                //       context,
                //       MaterialPageRoute(builder: (context) => const ShoppingCartPage()),
                //     );
                //   },
                // ),
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
                ...widget.artItems.map((artItem) => Container(
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
