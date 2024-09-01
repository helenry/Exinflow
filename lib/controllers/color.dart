import 'package:get/get.dart';

class ColorController extends GetxController {
  var selectedColor = ''.obs;

  void changeColor(String color) {
    selectedColor.value = color;
  }
}