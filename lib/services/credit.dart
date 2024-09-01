import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exinflow/models/credit.dart';
import 'package:get/get.dart';
import 'package:exinflow/controllers/currency.dart';
import 'package:exinflow/controllers/credit.dart';

class CreditService {
  Timestamp timestamp = Timestamp.now();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CreditController creditController = Get.find<CreditController>();
  final CurrencyController currencyController = Get.find<CurrencyController>();

  Future<Map<String, dynamic>> createMonthlyLimit(String uid, String id, Limit input) async {
    try {
      DocumentReference document = FirebaseFirestore.instance.collection('Categories').doc(id);

      await document.update({
        'Limits': FieldValue.arrayUnion([{
          'Month_Year': input.monthYear,
          'Limit': input.limit,
        }])
      });

      print({
        'success': true,
        'message': 'Sukses membuat limit kredit bulanan'
      });
      return {
        'success': true,
        'message': 'Sukses membuat limit kredit bulanan'
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

  Future<Map<String, dynamic>> updateMonthlyLimit(String uid, String id, int index, double limit) async {
    try {
      DocumentReference document = FirebaseFirestore.instance.collection('Categories').doc(id);

      DocumentSnapshot snapshot = await document.get();
      List<dynamic> limits = snapshot.get('Limits');

      limits[index] = {
        ...limits[index],
        'Limit': limit,
      };

      await document.update({'Limits': limits});

      print({
        'success': true,
        'message': 'Sukses mengubah limit kredit bulanan'
      });
      return {
        'success': true,
        'message': 'Sukses mengubah limit kredit bulanan'
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

  Future<Map<String, dynamic>> createCredit(String uid, CreditModel input) async {
    try {
      CollectionReference collection = FirebaseFirestore.instance.collection('Credits');

      await collection.add({
        'Provider': input.provider,
        'Limit_Amount': input.limitAmount,
        'Currency': input.currency,
        'Type_Id': input.typeId,
        'Limits': null,
        'Installments': null,
        'Due_Date': input.dueDate,
        'Cut_Off_Date': input.cutOffDate,
        'Icon': input.icon,
        'Color': input.color,
        'User': uid,
        'Updated_By': null,
        'Updated_At': null,
        'Created_By': uid,
        'Created_At': timestamp,
        'Is_Deleted': false,
      });

      Set<String> uniqueCurrenciesSet = {};
      for (var credit in creditController.credits.value) {
        uniqueCurrenciesSet.add(credit.currency);
      }
      List<String> uniqueCurrenciesList = uniqueCurrenciesSet.toList();
      currencyController.setCurrencies(uniqueCurrenciesList);

      print({
        'success': true,
        'message': 'Sukses membuat kredit'
      });
      return {
        'success': true,
        'message': 'Sukses membuat kredit'
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

  Future<Map<String, dynamic>> updateCredit(String uid, String id, CreditModel input) async {
    try {
      DocumentReference document = FirebaseFirestore.instance.collection('Credits').doc(id);

      await document.update({
        'Provider': input.provider,
        'Limit_Amount': input.limitAmount,
        'Currency': input.currency,
        'Type_Id': input.typeId,
        'Due_Date': input.dueDate,
        'Cut_Off_Date': input.cutOffDate,
        'Icon': input.icon,
        'Color': input.color,
        'Updated_By': uid,
        'Updated_At': timestamp,
      });

      Set<String> uniqueCurrenciesSet = {};
      for (var credit in creditController.credits.value) {
        uniqueCurrenciesSet.add(credit.currency);
      }
      List<String> uniqueCurrenciesList = uniqueCurrenciesSet.toList();
      currencyController.setCurrencies(uniqueCurrenciesList);

      print({
        'success': true,
        'message': 'Sukses mengubah kredit'
      });
      return {
        'success': true,
        'message': 'Sukses mengubah kredit'
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
  
  Future<Map<String, dynamic>> deleteCredit(String uid, String id) async {
    try {
      DocumentReference document = FirebaseFirestore.instance.collection('Credits').doc(id);

      await document.update({
        'Is_Deleted': true,
        'Updated_By': uid,
        'Updated_At': timestamp
      });

      Set<String> uniqueCurrenciesSet = {};
      for (var credit in creditController.credits.value) {
        uniqueCurrenciesSet.add(credit.currency);
      }
      List<String> uniqueCurrenciesList = uniqueCurrenciesSet.toList();
      currencyController.setCurrencies(uniqueCurrenciesList);

      print({
        'success': true,
        'message': 'Sukses menghapus kredit'
      });
      return {
        'success': true,
        'message': 'Sukses menghapus kredit'
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