import 'package:get/get.dart';

class CurrencyController extends GetxController {
  List<String>? usedCurrencies;

  void setCurrencies(List<String> currencies) {
    usedCurrencies = currencies;
  }
}