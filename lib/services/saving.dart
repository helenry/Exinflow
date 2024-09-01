import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exinflow/models/saving.dart';
import 'package:get/get.dart';
import 'package:exinflow/controllers/currency.dart';
import 'package:exinflow/controllers/saving.dart';

class SavingService {
  Timestamp timestamp = Timestamp.now();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final SavingController savingController = Get.find<SavingController>();
  final CurrencyController currencyController = Get.find<CurrencyController>();

  Future<Map<String, dynamic>> createRecord(String uid, String id, Record input) async {
    try {
      DocumentReference document = FirebaseFirestore.instance.collection('Savings').doc(id);

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

      await collection.add({
        'Target_Amount': input.targetAmount,
        'Currency': input.currency,
        'Category': input.category,
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
        'Category': input.category,
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