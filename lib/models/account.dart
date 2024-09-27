import 'package:cloud_firestore/cloud_firestore.dart';

class AccountModel {
  String _id;
  String _name;
  double _amount;
  String _currency;
  String _icon;
  String _color;
  bool _isDeleted;
  
  AccountModel({
    required String id,
    required String name,
    required double amount,
    required String currency,
    required String icon,
    required String color,
    required bool isDeleted,
  }) : _id = id,
  _name = name,
  _amount = amount,
  _currency = currency,
  _icon = icon,
  _color = color,
  _isDeleted = isDeleted;

  String get id => _id;
  String get name => _name;
  double get amount => _amount;
  String get currency => _currency;
  String get icon => _icon;
  String get color => _color;
  bool get isDeleted => _isDeleted;

  set name(String value) { _name = value; }
  set amount(double value) { _amount = value; }
  set currency(String value) { _currency = value; }
  set icon(String value) { _icon = value; }
  set color(String value) { _color = value; }
  set isDeleted(bool value) { _isDeleted = value; }
  
  factory AccountModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return AccountModel(
      id: doc.id,
      name: doc['Name'],
      amount: (doc['Amount'] as num).toDouble(),
      currency: doc['Currency'],
      icon: doc['Icon'],
      color: doc['Color'].toString(),
      isDeleted: doc['Is_Deleted'],
    );
  }
}