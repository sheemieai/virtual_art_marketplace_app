import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:virtual_marketplace_app/db/firestore_db.dart';

class CurrencyHelper {
  static final FirebaseDb firebaseDb = FirebaseDb();
  static const String apiUrl = "http://apilayer.net/api/live";
  static const List<String> supportedCurrencies = ["USD", "EUR", "GBP"];

  /// Fetch exchange rates for the given base currency
  static Future<Map<String, double>> fetchExchangeRates(final String baseCurrency) async {
    try {
      final String apiKey = await firebaseDb.fetchCurrencyLayerApiKey();
      final response = await http.get(
        Uri.parse("$apiUrl?access_key=$apiKey&currencies=${supportedCurrencies.join(',')}&source=$baseCurrency"),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"] == true) {
          Map<String, dynamic> quotes = data['quotes'];
          return quotes.map((key, value) {
            String currency = key.replaceFirst(baseCurrency, "");
            return MapEntry(currency, value.toDouble());
          });
        } else {
          throw Exception("Failed to fetch exchange rates: ${data['error']['info']}");
        }
      } else {
        throw Exception("Failed to connect to the CurrencyLayer API.");
      }
    } catch (e) {
      print("Error fetching exchange rates: $e");
      throw Exception("Error fetching exchange rates: $e");
    }
  }

  /// Convert a given amount to the target currency
  static double convert(final double amount, final String targetCurrency, final Map<String, double> exchangeRates) {
    print("amount: ${amount}, targetCurrency: ${targetCurrency}, exchangeRates: ${exchangeRates}");
    if (!exchangeRates.containsKey(targetCurrency)) {
      throw Exception("Exchange rate for $targetCurrency not available.");
    }
    return amount * exchangeRates[targetCurrency]!;
  }
}