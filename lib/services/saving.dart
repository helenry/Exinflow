import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exinflow/models/account.dart';
import 'package:exinflow/models/saving.dart';
import 'package:get/get.dart';
import 'package:exinflow/controllers/currency.dart';
import 'package:exinflow/controllers/saving.dart';
import 'package:exinflow/controllers/account.dart';
import 'package:exinflow/services/account.dart';

class SavingService {
  Timestamp timestamp = Timestamp.now();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final SavingController savingController = Get.find<SavingController>();
  final CurrencyController currencyController = Get.find<CurrencyController>();
  final AccountController accountController = Get.find<AccountController>();
  final AccountService accountService = AccountService();

  Future<Map<String, dynamic>> createRecord(String uid, String id, Record input) async {
    try {
      DocumentReference document = FirebaseFirestore.instance.collection('Savings').doc(id);

      Map<String, dynamic> result = {
        'success': false,
        'message': ''
      };

      AccountModel account = accountController.accounts.firstWhere((account) => account.id == input.accountId);

      result = await accountService.updateAccount(uid, account.id, AccountModel(
        id: '',
        name: account.name,
        amount: input.typeId == 0 ? account.amount + input.amount : account.amount - input.amount,
        currency: account.currency,
        icon: account.icon,
        color: account.color,
        isDeleted: false
      ));

      if(result['success']) {
        await document.update({
          'Records': FieldValue.arrayUnion([{
            'Amount': input.amount,
            'Account_Id': input.accountId,
            'Type_Id': input.typeId,
            'Date': input.date,
            'Updated_By': null,
            'Updated_At': null,
            'Created_By': uid,
            'Created_At': timestamp,
            'Is_Deleted': false,
          }])
        });

        print({
          'success': true,
          'message': 'Sukses menambah catatan tabungan'
        });
        return {
          'success': true,
          'message': 'Sukses menambah catatan tabungan'
        };
      } else {
        print({
          'success': true,
          'message': 'Gagal menambah catatan tabungan'
        });
        return {
          'success': true,
          'message': 'Gagal menambah catatan tabungan'
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

  Future<Map<String, dynamic>> updateRecord(String uid, String id, int index, Record input) async {
    try {
      DocumentReference document = FirebaseFirestore.instance.collection('Savings').doc(id);

      DocumentSnapshot snapshot = await document.get();
      List<dynamic> records = snapshot.get('Records');

      Map<String, dynamic> result = {
        'success': false,
        'message': ''
      };

      if(input.accountId != records[index]['Account_Id']) {
        AccountModel oldAccount = accountController.accounts.firstWhere((account) => account.id == records[index]['Account_Id']);
        AccountModel newAccount = accountController.accounts.firstWhere((account) => account.id == input.accountId);
        
        Map<String, dynamic> oldResult = await accountService.updateAccount(uid, oldAccount.id, AccountModel(
          id: '',
          name: oldAccount.name,
          amount: input.typeId == 0 ? oldAccount.amount - records[index]['Amount'] : oldAccount.amount + records[index]['Amount'],
          currency: oldAccount.currency,
          icon: oldAccount.icon,
          color: oldAccount.color,
          isDeleted: false
        ));
        
        Map<String, dynamic> newResult = await accountService.updateAccount(uid, newAccount.id, AccountModel(
          id: '',
          name: newAccount.name,
          amount: input.typeId == 0 ? newAccount.amount + records[index]['Amount'] : newAccount.amount - records[index]['Amount'],
          currency: newAccount.currency,
          icon: newAccount.icon,
          color: newAccount.color,
          isDeleted: false
        ));

        if(oldResult['success'] == true && newResult['success'] == true) {
          result = {
            'success': newResult['success'],
            'message': newResult['message']
          };
        } else {
          result = {
            'success': false,
            'message': 'Gagal mengubah akun'
          };
        }
      } else {
        AccountModel account = accountController.accounts.firstWhere((account) => account.id == input.accountId);

        result = await accountService.updateAccount(uid, account.id, AccountModel(
          id: '',
          name: account.name,
          amount: input.typeId == 0 ? account.amount - records[index]['Amount'] + input.amount : account.amount + records[index]['Amount'] - input.amount,
          currency: account.currency,
          icon: account.icon,
          color: account.color,
          isDeleted: false
        ));
      }

      if(result['success']) {
        records[index] = {
          ...records[index],
          'Amount': input.amount,
          'Account_Id': input.accountId,
          'Type_Id': input.typeId,
          'Date': input.date,
          'Updated_By': uid,
          'Updated_At': timestamp,
        };

        await document.update({'Records': records});

        print({
          'success': true,
          'message': 'Sukses mengubah catatan tabungan'
        });
        return {
          'success': true,
          'message': 'Sukses mengubah catatan tabungan'
        };
      } else {
        print({
          'success': true,
          'message': 'Gagal mengubah catatan tabungan'
        });
        return {
          'success': true,
          'message': 'Gagal mengubah catatan tabungan'
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

  Future<Map<String, dynamic>> deleteRecord(String uid, String id, int index) async {
    try {
      DocumentReference document = FirebaseFirestore.instance.collection('Savings').doc(id);

      DocumentSnapshot snapshot = await document.get();
      List<dynamic> records = snapshot.get('Records');

      Map<String, dynamic> result = {
        'success': false,
        'message': ''
      };

      AccountModel account = accountController.accounts.firstWhere((account) => account.id == records[index]['Account_Id']);

      result = await accountService.updateAccount(uid, account.id, AccountModel(
        id: '',
        name: account.name,
        amount: records[index]['Type_Id'] == 0 ? account.amount - records[index]['Amount'] : account.amount + records[index]['Amount'],
        currency: account.currency,
        icon: account.icon,
        color: account.color,
        isDeleted: false
      ));

      records[index] = {
        ...records[index],
        'Is_Deleted': true,
        'Updated_By': uid,
        'Updated_At': timestamp,
      };

      await document.update({'Records': records});

      print({
        'success': true,
        'message': 'Sukses menghapus catatan tabungan'
      });
      return {
        'success': true,
        'message': 'Sukses menghapus catatan tabungan'
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

  Future<Map<String, dynamic>> createSaving(String uid, SavingModel input) async {
    try {
      CollectionReference collection = FirebaseFirestore.instance.collection('Savings');

      print({
        'Target_Amount': input.targetAmount,
        'Currency': input.currency,
        'Category': {
          'Id': input.category.id,
          'Sub_Id': input.category.subId
        },
        'Name': input.name,
        'Note': input.note,
        'Due_Date': input.dueDate,
        'Records': null,
        'User': uid,
        'Updated_By': null,
        'Updated_At': null,
        'Created_By': uid,
        'Created_At': timestamp,
        'Is_Deleted': false,
      });

      await collection.add({
        'Target_Amount': input.targetAmount,
        'Currency': input.currency,
        'Category': {
          'Id': input.category.id,
          'Sub_Id': input.category.subId
        },
        'Name': input.name,
        'Note': input.note,
        'Due_Date': input.dueDate,
        'Records': null,
        'User': uid,
        'Updated_By': null,
        'Updated_At': null,
        'Created_By': uid,
        'Created_At': timestamp,
        'Is_Deleted': false,
      });

      Set<String> uniqueCurrenciesSet = {};
      for (var saving in savingController.savings.value) {
        uniqueCurrenciesSet.add(saving.currency);
      }
      List<String> uniqueCurrenciesList = uniqueCurrenciesSet.toList();
      currencyController.setCurrencies(uniqueCurrenciesList);

      print({
        'success': true,
        'message': 'Sukses membuat tabungan'
      });
      return {
        'success': true,
        'message': 'Sukses membuat tabungan'
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

  Future<Map<String, dynamic>> updateSaving(String uid, String id, SavingModel input) async {
    try {
      DocumentReference document = FirebaseFirestore.instance.collection('Savings').doc(id);

      await document.update({
        'Target_Amount': input.targetAmount,
        'Currency': input.currency,
        'Category': {
          'Id': input.category.id,
          'Sub_Id': input.category.subId
        },
        'Name': input.name,
        'Note': input.note,
        'Due_Date': input.dueDate,
        'Updated_By': uid,
        'Updated_At': timestamp,
      });

      Set<String> uniqueCurrenciesSet = {};
      for (var saving in savingController.savings.value) {
        uniqueCurrenciesSet.add(saving.currency);
      }
      List<String> uniqueCurrenciesList = uniqueCurrenciesSet.toList();
      currencyController.setCurrencies(uniqueCurrenciesList);

      print({
        'success': true,
        'message': 'Sukses mengubah tabungan'
      });
      return {
        'success': true,
        'message': 'Sukses mengubah tabungan'
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
  
  Future<Map<String, dynamic>> deleteSaving(String uid, String id) async {
    try {
      DocumentReference document = FirebaseFirestore.instance.collection('Savings').doc(id);

      await document.update({
        'Is_Deleted': true,
        'Updated_By': uid,
        'Updated_At': timestamp
      });

      Set<String> uniqueCurrenciesSet = {};
      for (var saving in savingController.savings.value) {
        uniqueCurrenciesSet.add(saving.currency);
      }
      List<String> uniqueCurrenciesList = uniqueCurrenciesSet.toList();
      currencyController.setCurrencies(uniqueCurrenciesList);

      print({
        'success': true,
        'message': 'Sukses menghapus tabungan'
      });
      return {
        'success': true,
        'message': 'Sukses menghapus tabungan'
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