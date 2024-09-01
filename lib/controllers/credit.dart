import 'package:exinflow/models/credit.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class CreditController extends GetxController {
  var credits = <CreditModel>[].obs;
  CreditModel? credit;

  @override
  void onInit() {
    super.onInit();
    credits.bindStream(getCredits());
  }

  Stream<List<CreditModel>> getCredits() {
    return FirebaseAuth.instance.authStateChanges().switchMap((User? user) {
      if (user == null) {
        return Stream<List<CreditModel>>.empty();
      }

      return FirebaseFirestore.instance
          .collection('Credits')
          .where('User', isEqualTo: user.uid)
          .snapshots()
          .map((QuerySnapshot query) {
        return query.docs.map((doc) => CreditModel.fromDocumentSnapshot(doc)).toList();
      });
    });
  }

  void setCredit(CreditModel selected) {
    credit = selected;
  }
}