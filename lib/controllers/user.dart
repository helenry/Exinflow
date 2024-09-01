import 'package:exinflow/models/user.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  UserModel? user;

  void setUser(UserModel newUser) {
    user = newUser;
  }
}