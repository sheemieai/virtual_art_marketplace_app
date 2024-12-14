import 'currency_helper.dart';

class ExchangeRateHelper {
  static final ExchangeRateHelper instance = ExchangeRateHelper.internal();

  factory ExchangeRateHelper() => instance;

  Map<String, double> exchangeRates = {
    "USD": 1.0,
    "EUR": 1.0,
    "GBP": 1.0,
  };

  bool isFetched = false;

  ExchangeRateHelper.internal();

  // Fetch and initialize exchange rates
  Future<void> initializeExchangeRates(final String baseCurrency) async {
    if (!isFetched) {
      try {
        final fetchedRates = await CurrencyHelper.fetchExchangeRates(baseCurrency);
        exchangeRates = {
          "USD": fetchedRates["USD"] ?? 1.0,
          "EUR": fetchedRates["EUR"] ?? 1.0,
          "GBP": fetchedRates["GBP"] ?? 1.0,
        };
        isFetched = true;
        print("Exchange rates initialized: $exchangeRates");
      } catch (e) {
        print("Error fetching exchange rates: $e");
      }
    }
  }

  // Reset rates if needed
  void reset() {
    isFetched = false;
  }
}
