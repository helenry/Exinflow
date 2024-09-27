import 'package:exinflow/models/user.dart';
import 'package:exinflow/services/user.dart';

import 'router.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:exinflow/constants/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:exinflow/controllers/onboarding.dart';
import 'package:exinflow/controllers/user.dart';
import 'package:exinflow/controllers/account.dart';
import 'package:exinflow/controllers/category.dart';
import 'package:exinflow/controllers/transaction.dart';
import 'package:exinflow/controllers/credit.dart';
import 'package:exinflow/controllers/saving.dart';
import 'package:exinflow/controllers/subtab.dart';
import 'package:exinflow/controllers/icon.dart';
import 'package:exinflow/controllers/color.dart';
import 'package:exinflow/controllers/currency.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.put(OnboardingController());
  Get.put(UserController());
  Get.put(CurrencyController());
  Get.put(AccountController());
  Get.put(CategoryController());
  Get.put(TransactionController());
  Get.put(CreditController());
  Get.put(SavingController());
  Get.put(AllSubtabController());
  Get.put(OneSubtabController());
  Get.put(IconController());
  Get.put(ColorController());

  await initializeDateFormatting('id_ID', null);

  final user = FirebaseAuth.instance.currentUser;
  final UserService userService = UserService();
  final UserController userController = Get.find<UserController>();

  if(user != null) {
    Map<String, dynamic> existingData = await userService.getUserData(user.uid);

    userController.setUser(
      UserModel(
        uid: user.uid,
        email: user.email ?? '',
        fullName: existingData['data'].get('Full_Name'),
        mainCurrency: existingData['data'].get('Main_Currency')
      )
    );
  }

  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,

      debugShowCheckedModeBanner: false,

      title: "exinflow",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: mainBlue),
        useMaterial3: true,
        primaryColor: mainBlue,
        scaffoldBackgroundColor: mainBlueMinusSix,
        fontFamily: "Inter"
      ),
    );
  }
}