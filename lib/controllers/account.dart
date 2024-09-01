import 'package:exinflow/models/account.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class AccountController extends GetxController {
  var accounts = <AccountModel>[].obs;
  AccountModel? account;
  int accountLength = 0;

  @override
  void onInit() {
    super.onInit();
    accounts.bindStream(getAccounts());
  }

  Stream<List<AccountModel>> getAccounts() {
    return FirebaseAuth.instance.authStateChanges().switchMap((User? user) {
      if (user == null) {
        return Stream<List<AccountModel>>.empty();
      }

      return FirebaseFirestore.instance
          .collection('Accounts')
          .where('User', isEqualTo: user.uid)
          .snapshots()
          .map((QuerySnapshot query) {
        return query.docs.map((doc) => AccountModel.fromDocumentSnapshot(doc)).toList();
      });
    });
  }

  void setAccount(AccountModel selected) {
    account = selected;
  }

  void setLength(int length) {
    accountLength = length;
  }
}