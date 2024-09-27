import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exinflow/models/category.dart';

class CategoryService {
  Timestamp timestamp = Timestamp.now();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> createCategory(String uid, bool automatic, CategoryModel input) async {
    try {
      CollectionReference collection = FirebaseFirestore.instance.collection('Categories');

      DocumentReference document = await collection.add({
        'Name': input.name,
        'Type_Id': input.typeId,
        'Subs': null,
        'Icon': input.icon,
        'Color': input.color,
        'User': uid,
        'Updated_By': null,
        'Updated_At': null,
        'Created_By': automatic == true ? 'SysAdmin' : uid,
        'Created_At': timestamp,
        'Is_Deleted': false,
      });

      print({
        'success': true,
        'message': 'Sukses membuat kategori',
        'id': document.id
      });
      return {
        'success': true,
        'message': 'Sukses membuat kategori',
        'id': document.id
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

  Future<Map<String, dynamic>> createSubcategory(String uid, bool automatic, String parent, SubcategoryModel input) async {
    try {
      DocumentReference document = FirebaseFirestore.instance.collection('Categories').doc(parent);

      await document.update({
        'Subs': FieldValue.arrayUnion([{
          'Name': input.name,
          'Icon': input.icon,
          'Updated_By': null,
          'Updated_At': null,
          'Created_By': automatic == true ? 'SysAdmin' : uid,
          'Created_At': timestamp,
          'Is_Deleted': false,
        }])
      });

      print({
        'success': true,
        'message': 'Sukses membuat subkategori'
      });
      return {
        'success': true,
        'message': 'Sukses membuat subkategori'
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

  Future<Map<String, dynamic>> updateCategory(String uid, String id, CategoryModel input) async {
    try {
      DocumentReference document = FirebaseFirestore.instance.collection('Categories').doc(id);

      await document.update({
        'Name': input.name,
        'Icon': input.icon,
        'Color': input.color,
        'Updated_By': uid,
        'Updated_At': timestamp,
      });

      print({
        'success': true,
        'message': 'Sukses mengubah kategori',
      });
      return {
        'success': true,
        'message': 'Sukses mengubah kategori',
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

  Future<Map<String, dynamic>> updateSubcategory(String uid, String id, int index, SubcategoryModel input) async {
    try {
      DocumentReference document = FirebaseFirestore.instance.collection('Categories').doc(id);

      DocumentSnapshot snapshot = await document.get();
      List<dynamic> subs = snapshot.get('Subs');

      subs[index] = {
        ...subs[index],
        'Name': input.name,
        'Icon': input.icon,
        'Updated_By': uid,
        'Updated_At': timestamp,
      };

      await document.update({'Subs': subs});

      print({
        'success': true,
        'message': 'Sukses mengubah subkategori',
      });
      return {
        'success': true,
        'message': 'Sukses mengubah subkategori',
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

  Future<Map<String, dynamic>> deleteCategory(String uid, String id) async {
    try {
      DocumentReference document = FirebaseFirestore.instance.collection('Categories').doc(id);

      await document.update({
        'Is_Deleted': true,
        'Updated_By': uid,
        'Updated_At': timestamp,
      });

      print({
        'success': true,
        'message': 'Sukses menghapus kategori',
      });
      return {
        'success': true,
        'message': 'Sukses menghapus kategori',
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

  Future<Map<String, dynamic>> deleteSubcategory(String uid, String id, int index) async {
    try {
      DocumentReference document = FirebaseFirestore.instance.collection('Categories').doc(id);

      DocumentSnapshot snapshot = await document.get();
      List<dynamic> subs = snapshot.get('Subs');

      subs[index] = {
        ...subs[index],
        'Is_Deleted': true,
        'Updated_By': uid,
        'Updated_At': timestamp,
      };

      await document.update({'Subs': subs});

      print({
        'success': true,
        'message': 'Sukses menghapus subkategori',
      });
      return {
        'success': true,
        'message': 'Sukses menghapus subkategori',
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

  Future<Map<String, dynamic>> createStarters(String uid) async {
    try {
      Map<String, dynamic> one = await createCategory(
        uid,
        true,
        CategoryModel(
          id: '',
          name: 'Makanan & Minuman',
          typeId: 0,
          subs: null,
          icon: 'restaurant_rounded',
          color: 'f44336',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        one['id'],
        SubcategoryModel(
          name: 'Bahan Makanan',
          icon: 'egg_alt_outlined',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        one['id'],
        SubcategoryModel(
          name: 'Restoran & Café',
          icon: 'fastfood_outlined',
          isDeleted: false
        )
      );
      
      Map<String, dynamic> two = await createCategory(
        uid,
        true,
        CategoryModel(
          id: '',
          name: 'Transportasi',
          typeId: 0,
          subs: null,
          icon: 'airport_shuttle_outlined',
          color: '2196f3',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        two['id'],
        SubcategoryModel(
          name: 'Motor',
          icon: 'two_wheeler_rounded',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        two['id'],
        SubcategoryModel(
          name: 'Mobil',
          icon: 'directions_car_outlined',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        two['id'],
        SubcategoryModel(
          name: 'Bus',
          icon: 'directions_bus_outlined',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        two['id'],
        SubcategoryModel(
          name: 'Kereta Api',
          icon: 'directions_subway_outlined',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        two['id'],
        SubcategoryModel(
          name: 'Kapal',
          icon: 'directions_ferry_outlined',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        two['id'],
        SubcategoryModel(
          name: 'Pesawat',
          icon: 'airplanemode_on_rounded',
          isDeleted: false
        )
      );
      
      Map<String, dynamic> three = await createCategory(
        uid,
        true,
        CategoryModel(
          id: '',
          name: 'Hiburan',
          typeId: 0,
          subs: null,
          icon: 'attractions_outlined',
          color: 'e91e63',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        three['id'],
        SubcategoryModel(
          name: 'Game',
          icon: 'videogame_asset_outlined',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        three['id'],
        SubcategoryModel(
          name: 'Film',
          icon: 'movie_creation_outlined',
          isDeleted: false
        )
      );
      
      Map<String, dynamic> four = await createCategory(
        uid,
        true,
        CategoryModel(
          id: '',
          name: 'Pemberian & Amal',
          typeId: 0,
          subs: null,
          icon: 'local_florist_outlined',
          color: '9c27b0',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        four['id'],
        SubcategoryModel(
          name: 'Donasi',
          icon: 'volunteer_activism_outlined',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        four['id'],
        SubcategoryModel(
          name: 'Pernikahan',
          icon: 'favorite_outline_rounded',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        four['id'],
        SubcategoryModel(
          name: 'Pemakaman',
          icon: 'person_remove_outlined',
          isDeleted: false
        )
      );
      
      Map<String, dynamic> five = await createCategory(
        uid,
        true,
        CategoryModel(
          id: '',
          name: 'Biaya & Tagihan',
          typeId: 0,
          subs: null,
          icon: 'receipt_long_rounded',
          color: '795548',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        five['id'],
        SubcategoryModel(
          name: 'Listrik',
          icon: 'bolt_rounded',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        five['id'],
        SubcategoryModel(
          name: 'Air',
          icon: 'water_drop_outlined',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        five['id'],
        SubcategoryModel(
          name: 'Internet',
          icon: 'wifi_rounded',
          isDeleted: false
        )
      );
      
      Map<String, dynamic> six = await createCategory(
        uid,
        true,
        CategoryModel(
          id: '',
          name: 'Keluarga & Rumah Tangga',
          typeId: 0,
          subs: null,
          icon: 'house_outlined',
          color: '009688',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        six['id'],
        SubcategoryModel(
          name: 'Anak',
          icon: 'child_friendly_outlined',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        six['id'],
        SubcategoryModel(
          name: 'Binatang Peliharaan',
          icon: 'pets_rounded',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        six['id'],
        SubcategoryModel(
          name: 'Perabotan',
          icon: 'weekend_outlined',
          isDeleted: false
        )
      );
      
      Map<String, dynamic> seven = await createCategory(
        uid,
        true,
        CategoryModel(
          id: '',
          name: 'Kesehatan & Perawatan',
          typeId: 0,
          subs: null,
          icon: 'self_improvement_rounded',
          color: '4caf50',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        seven['id'],
        SubcategoryModel(
          name: 'Obat-obatan',
          icon: 'vaccines_outlined',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        seven['id'],
        SubcategoryModel(
          name: 'Olahraga',
          icon: 'fitness_center_rounded',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        seven['id'],
        SubcategoryModel(
          name: 'Perawatan Pribadi',
          icon: 'spa_outlined',
          isDeleted: false
        )
      );

      Map<String, dynamic> eight = await createCategory(
        uid,
        true,
        CategoryModel(
          id: '',
          name: 'Belanja',
          typeId: 0,
          subs: null,
          icon: 'local_mall_outlined',
          color: 'ff9800',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        eight['id'],
        SubcategoryModel(
          name: 'Pakaian',
          icon: 'dry_cleaning_outlined',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        eight['id'],
        SubcategoryModel(
          name: 'Elektronik',
          icon: 'devices_rounded',
          isDeleted: false
        )
      );

      await createCategory(
        uid,
        true,
        CategoryModel(
          id: '',
          name: 'Liburan',
          typeId: 0,
          subs: null,
          icon: 'beach_access_outlined',
          color: '3f51b5',
          isDeleted: false
        )
      );

      await createCategory(
        uid,
        true,
        CategoryModel(
          id: '',
          name: 'Pendidikan',
          typeId: 0,
          subs: null,
          icon: 'school_outlined',
          color: 'ffeb3b',
          isDeleted: false
        )
      );

      Map<String, dynamic> eleven = await createCategory(
        uid,
        true,
        CategoryModel(
          id: '',
          name: 'Gaji',
          typeId: 1,
          subs: null,
          icon: 'work_outline',
          color: 'ffeb3b',
          isDeleted: false
        )
      );
      await createSubcategory(
        uid,
        true,
        eleven['id'],
        SubcategoryModel(
          name: 'Bonus',
          icon: 'attach_money_rounded',
          isDeleted: false
        )
      );

      await createCategory(
        uid,
        true,
        CategoryModel(
          id: '',
          name: 'Hadiah',
          typeId: 1,
          subs: null,
          icon: 'card_giftcard_rounded',
          color: 'e91e63',
          isDeleted: false
        )
      );

      await createCategory(
        uid,
        true,
        CategoryModel(
          id: '',
          name: 'Pensiun',
          typeId: 1,
          subs: null,
          icon: 'elderly_rounded',
          color: '795548',
          isDeleted: false
        )
      );

      await createCategory(
        uid,
        true,
        CategoryModel(
          id: '',
          name: 'Investasi',
          typeId: 1,
          subs: null,
          icon: 'ssid_chart_rounded',
          color: '2196f3',
          isDeleted: false
        )
      );

      await createCategory(
        uid,
        true,
        CategoryModel(
          id: '',
          name: 'Keuntungan',
          typeId: 1,
          subs: null,
          icon: 'store_outlined',
          color: '4caf50',
          isDeleted: false
        )
      );

      print({
        'success': true,
        'message': 'Sukses membuat kategori default'
      });
      return {
        'success': true,
        'message': 'Sukses membuat kategori default'
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