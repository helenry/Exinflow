import 'package:exinflow/models/category.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryController extends GetxController {
  var categories = <CategoryModel>[].obs;
  CategoryModel? category;
  int subcategory = -1;
  int categoryLength = 0;

  @override
  void onInit() {
    super.onInit();
    categories.bindStream(getCategories());
  }

  Stream<List<CategoryModel>> getCategories() {
    return FirebaseAuth.instance.authStateChanges().switchMap((User? user) {
      if (user == null) {
        return Stream<List<CategoryModel>>.empty();
      }

      return FirebaseFirestore.instance
          .collection('Categories')
          .where('User', isEqualTo: user.uid)
          .snapshots()
          .map((QuerySnapshot query) {
        return query.docs.map((doc) => CategoryModel.fromDocumentSnapshot(doc)).toList();
      });
    });
  }

  void setCategory(CategoryModel selected) {
    category = selected;
  }

  void setSubcategory(int selected) {
    subcategory = selected;
  }

  void setLength(int length) {
    categoryLength = length;
  }
}