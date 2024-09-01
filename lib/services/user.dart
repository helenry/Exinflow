import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exinflow/controllers/user.dart';
import 'package:exinflow/controllers/currency.dart';
import 'package:exinflow/controllers/account.dart';
import 'package:get/get.dart';
import 'package:exinflow/models/user.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserService {
  final authentication = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final UserController userController = Get.find<UserController>();
  final AccountController accountController = Get.find<AccountController>();
  final CurrencyController currencyController = Get.find<CurrencyController>();

  // Future<Map<String, dynamic>> googleSignUp(String email) async {
  //   try {
  //     final GoogleSignInAccount? googleAccount = await GoogleSignIn().signIn();
  //     final GoogleSignInAuthentication? googleAuthentication = await googleAccount?.authentication;

  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuthentication?.accessToken,
  //       idToken: googleAuthentication?.idToken,
  //     );
  //     UserCredential userCredential = await authentication.signInWithCredential(credential);

  //     if(userCredential.user != null) {
  //       Map<String, dynamic> existingData = await getUserData(userCredential.user?.uid ?? '');

  //       userController.setUser(
  //         UserModel(
  //           uid: userCredential.user?.uid ?? '',
  //           email: email,
  //           fullName: existingData['data'].get('Full_Name'),
  //           mainCurrency: existingData['data'].get('Main_Currency')
  //         )
  //       );

  //       print({
  //         'success': true,
  //         'message': 'Sukses masuk ke akun'
  //       });
  //       return {
  //         'success': true,
  //         'message': 'Sukses masuk ke akun'
  //       };
  //     } else {
  //       print({
  //         'success': false,
  //         'message': 'Gagal masuk ke akun'
  //       });
  //       return {
  //         'success': false,
  //         'message': 'Gagal masuk ke akun'
  //       };
  //     }
  //   } catch(e) {
  //     print({
  //       'success': false,
  //       'message': e.toString()
  //     });
  //     return {
  //       'success': false,
  //       'message': e.toString()
  //     };
  //   }
  // }

  Future<Map<String, dynamic>> emailSignUp(Map<String, dynamic> data) async {
    try {
      UserCredential userCredential = await authentication.createUserWithEmailAndPassword(
        email: data['email'],
        password: data['password']
      );

      if(userCredential.user != null) {
        DocumentReference document = firestore.collection('User_Data').doc(userCredential.user?.uid ?? '');
        await document.set({
          'Full_Name': data['fullName'],
          'Main_Currency': ''
        });

        userController.setUser(
          UserModel(
            uid: userCredential.user?.uid ?? '',
            email: data['email'],
            fullName: data['fullName'],
            mainCurrency: ''
          )
        );

        print({
          'success': true,
          'message': 'Sukses mendaftarkan akun'
        });
        return {
          'success': true,
          'message': 'Sukses mendaftarkan akun'
        };
      } else {
        print({
          'success': false,
          'message': 'Gagal mendaftarkan akun'
        });
        return {
          'success': false,
          'message': 'Gagal mendaftarkan akun'
        };
      }
    } catch(e) {
      print({
        'success': false,
        'message': e.toString()
      });
      return {
        'success': false,
        'message': e.toString()
      };
    }
  }

  Future<Map<String, dynamic>> emailSignIn(Map<String, dynamic> data) async {
    try {
      UserCredential userCredential = await authentication.signInWithEmailAndPassword(
        email: data['email'],
        password: data['password']
      );

      if(userCredential.user != null) {
        Map<String, dynamic> existingData = await getUserData(userCredential.user?.uid ?? '');

        userController.setUser(
          UserModel(
            uid: userCredential.user?.uid ?? '',
            email: data['email'],
            fullName: existingData['data'].get('Full_Name'),
            mainCurrency: existingData['data'].get('Main_Currency')
          )
        );

        print({
          'success': true,
          'message': 'Sukses masuk ke akun'
        });
        return {
          'success': true,
          'message': 'Sukses masuk ke akun'
        };
      } else {
        print({
          'success': false,
          'message': 'Gagal masuk ke akun'
        });
        return {
          'success': false,
          'message': 'Gagal masuk ke akun'
        };
      }
    } catch(e) {
      print({
        'success': false,
        'message': e.toString()
      });
      return {
        'success': false,
        'message': e.toString()
      };
    }
  }

  Future<Map<String, dynamic>> getUserData(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> document = await firestore.collection('User_Data').doc(uid).get();

      print({
        'success': true,
        'message': 'Sukses mengubah mata uang utama',
        'data': document
      });
      return {
        'success': true,
        'message': 'Sukses mengubah mata uang utama',
        'data': document
      };
    } catch(e) {
      print({
        'success': false,
        'message': e.toString()
      });
      return {
        'success': false,
        'message': e.toString()
      };
    }
  }

  Future<Map<String, dynamic>> modifyMainCurrency(String uid, String newCurrency) async {
    try {
      DocumentReference document = firestore.collection('User_Data').doc(uid);
      await document.update({ 'Main_Currency': newCurrency });

      userController.user?.setMainCurrency(newCurrency);

      Set<String> uniqueCurrenciesSet = {};
      for (var account in accountController.accounts.value) {
        uniqueCurrenciesSet.add(account.currency);
      }
      List<String> uniqueCurrenciesList = uniqueCurrenciesSet.toList();
      currencyController.setCurrencies(uniqueCurrenciesList);

      print({
        'success': true,
        'message': 'Sukses mengubah mata uang utama'
      });
      return {
        'success': true,
        'message': 'Sukses mengubah mata uang utama'
      };
    } catch(e) {
      print({
        'success': false,
        'message': e.toString()
      });
      return {
        'success': false,
        'message': e.toString()
      };
    }
  }

  Future<Map<String, dynamic>> modifyName(String uid, String name) async {
    try {
      DocumentReference document = firestore.collection('User_Data').doc(uid);
      await document.update({ 'Full_Name': name });

      userController.user?.setFullName(name);

      print({
        'success': true,
        'message': 'Sukses mengubah nama'
      });
      return {
        'success': true,
        'message': 'Sukses mengubah nama'
      };
    } catch(e) {
      print({
        'success': false,
        'message': e.toString()
      });
      return {
        'success': false,
        'message': e.toString()
      };
    }
  }
}