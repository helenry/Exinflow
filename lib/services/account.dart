import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:exinflow/controllers/currency.dart';
import 'package:exinflow/controllers/account.dart';
import 'package:exinflow/models/account.dart';

class AccountService {
  Timestamp timestamp = Timestamp.now();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final AccountController accountController = Get.find<AccountController>();
  final CurrencyController currencyController = Get.find<CurrencyController>();

  Future<Map<String, dynamic>> createAccount(String uid, bool automatic, AccountModel input) async {
    try {
      CollectionReference collection = FirebaseFirestore.instance.collection('Accounts');

      await collection.add({
        'Name': input.name,
        'Amount': input.amount,
        'Currency': input.currency,
        'Icon': input.icon,
        'Color': input.color,
        'User': uid,
        'Updated_By': null,
        'Updated_At': null,
        'Created_By': automatic == true ? 'SysAdmin' : uid,
        'Created_At': timestamp,
        'Is_Deleted': false,
      });

      Set<String> uniqueCurrenciesSet = {};
      for (var account in accountController.accounts.value) {
        uniqueCurrenciesSet.add(account.currency);
      }
      List<String> uniqueCurrenciesList = uniqueCurrenciesSet.toList();
      currencyController.setCurrencies(uniqueCurrenciesList);

      print({
        'success': true,
        'message': 'Sukses membuat akun'
      });
      return {
        'success': true,
        'message': 'Sukses membuat akun'
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

  Future<Map<String, dynamic>> updateAccount(String uid, String id, AccountModel input) async {
    try {
      DocumentReference document = FirebaseFirestore.instance.collection('Accounts').doc(id);

      await document.update({
        'Name': input.name,
        'Amount': input.amount,
        'Currency': input.currency,
        'Icon': input.icon,
        'Color': input.color,
        'Updated_By': uid,
        'Updated_At': timestamp,
      });

      Set<String> uniqueCurrenciesSet = {};
      for (var account in accountController.accounts.value) {
        uniqueCurrenciesSet.add(account.currency);
      }
      List<String> uniqueCurrenciesList = uniqueCurrenciesSet.toList();
      currencyController.setCurrencies(uniqueCurrenciesList);

      print({
        'success': true,
        'message': 'Sukses mengubah akun'
      });
      return {
        'success': true,
        'message': 'Sukses mengubah akun'
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
  
  Future<Map<String, dynamic>> deleteAccount(String uid, String id) async {
    try {
      DocumentReference document = FirebaseFirestore.instance.collection('Accounts').doc(id);

      await document.update({
        'Is_Deleted': true,
        'Updated_By': uid,
        'Updated_At': timestamp
      });

      Set<String> uniqueCurrenciesSet = {};
      for (var account in accountController.accounts.value) {
        uniqueCurrenciesSet.add(account.currency);
      }
      List<String> uniqueCurrenciesList = uniqueCurrenciesSet.toList();
      currencyController.setCurrencies(uniqueCurrenciesList);

      print({
        'success': true,
        'message': 'Sukses menghapus akun'
      });
      return {
        'success': true,
        'message': 'Sukses menghapus akun'
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