import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String _id;
  String _name;
  int _typeId;
  List<SubcategoryModel>? _subs;
  String _icon;
  String _color;
  
  CategoryModel({
    required String id,
    required String name,
    required int typeId,
    required List<SubcategoryModel>? subs,
    required String icon,
    required String color
  }) : _id = id,
  _name = name,
  _typeId = typeId,
  _subs = subs,
  _icon = icon,
  _color = color;

  String get id => _id;
  String get name => _name;
  int get typeId => _typeId;
  List<SubcategoryModel>? get subs => _subs;
  String get icon => _icon;
  String get color => _color;

  set name(String value) { _name = value; }
  set typeId(int value) { _typeId = value; }
  set icon(String value) { _icon = value; }
  set color(String value) { _color = value; }

  factory CategoryModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    List<SubcategoryModel>? subs = doc['Subs'] == null ? doc['Subs'] : (doc['Subs'] as List).map((sub) {
      return SubcategoryModel(name: sub['Name'], icon: sub['Icon']);
    }).toList();

    return CategoryModel(
      id: doc.id,
      name: doc['Name'],
      typeId: doc['Type_Id'],
      subs: subs,
      icon: doc['Icon'],
      color: doc['Color'].toString(),
    );
  }
}

class SubcategoryModel {
  String _name;
  String _icon;
  
  SubcategoryModel({
    required String name,
    required String icon,
  }) : _name = name,
  _icon = icon;

  String get name => _name;
  String get icon => _icon;

  set name(String value) { _name = value; }
  set icon(String value) { _icon = value; }
}