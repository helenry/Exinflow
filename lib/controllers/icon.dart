import 'package:get/get.dart';

class IconController extends GetxController {
  var selectedIcon = ''.obs;

  void changeIcon(String icon) {
    selectedIcon.value = icon;
  }
}