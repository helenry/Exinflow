import 'package:exinflow/models/saving.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavingController extends GetxController {
  var savings = <SavingModel>[].obs;
  SavingModel? saving;

  @override
  void onInit() {
    super.onInit();
    savings.bindStream(getSavings());
  }

  Stream<List<SavingModel>> getSavings() {
    return FirebaseAuth.instance.authStateChanges().switchMap((User? user) {
      if (user == null) {
        return Stream<List<SavingModel>>.empty();
      }

      return FirebaseFirestore.instance
          .collection('Savings')
          .where('User', isEqualTo: user.uid)
          .snapshots()
          .map((QuerySnapshot query) {
        return query.docs.map((doc) => SavingModel.fromDocumentSnapshot(doc)).toList();
      });
    });
  }

  void setSaving(SavingModel selected) {
    saving = selected;
  }
}