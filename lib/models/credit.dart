import "package:cloud_firestore/cloud_firestore.dart";
import "package:exinflow/models/common.dart";

class Limit {
  Timestamp _monthYear;
  double _limit;
  
  Limit({
    required Timestamp monthYear,
    required double limit,
  }) : _monthYear = monthYear,
  _limit = limit;

  Timestamp get monthYear => _monthYear;
  double get limit => _limit;
}

class Installment {
  String _name;
  double _amount;
  int _month;
  Timestamp _transactionDate;
  Category _category;
  String? _note;
  
  Installment({
    required String name,
    required double amount,
    required int month,
    required Timestamp transactionDate,
    required Category category,
    required String? note,
  }) : _name = name,
  _amount = amount,
  _month = month,
  _transactionDate = transactionDate,
  _category = category,
  _note = note;

  String get name => _name;
  double get amount => _amount;
  int get month => _month;
  Timestamp get transactionDate => _transactionDate;
  Category get category => _category;
  String? get note => _note;

  set name(String value) { _name = value; }
  set amount(double value) { _amount = value; }
  set month(int value) { _month = value; }
  set transactionDate(Timestamp value) { _transactionDate = value; }
  set category(Category value) { _category = value; }
  set note(String? value) { _note = value; }
}

class CreditModel {
  String _id;
  String _provider;
  double _limitAmount;
  String _currency;
  int _typeId;
  List<Limit>? _limits;
  List<Installment>? _installments;
  int _dueDate;
  int _cutOffDate;
  String _icon;
  String _color;
  bool _isDeleted;
  
  CreditModel({
    required String id,
    required String provider,
    required double limitAmount,
    required String currency,
    required int typeId,
    required List<Limit>? limits,
    required List<Installment>? installments,
    required int dueDate,
    required int cutOffDate,
    required String icon,
    required String color,
    required bool isDeleted,
  }) : _id = id,
  _provider = provider,
  _limitAmount = limitAmount,
  _currency = currency,
  _typeId = typeId,
  _limits = limits,
  _installments = installments,
  _dueDate = dueDate,
  _cutOffDate = cutOffDate,
  _icon = icon,
  _color = color,
  _isDeleted = isDeleted;

  String get id => _id;
  String get provider => _provider;
  double get limitAmount => _limitAmount;
  String get currency => _currency;
  int get typeId => _typeId;
  List<Limit>? get limits => _limits;
  List<Installment>? get installments => _installments;
  int get dueDate => _dueDate;
  int get cutOffDate => _cutOffDate;
  String get icon => _icon;
  String get color => _color;
  bool get isDeleted => _isDeleted;

  set provider(String value) { _provider = value; }
  set limitAmount(double value) { _limitAmount = value; }
  set currency(String value) { _currency = value; }
  set typeId(int value) { _typeId = value; }
  set dueDate(int value) { _dueDate = value; }
  set cutOffDate(int value) { _cutOffDate = value; }
  set icon(String value) { _icon = value; }
  set color(String value) { _color = value; }
  set isDeleted(bool value) { _isDeleted = value; }

  factory CreditModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return CreditModel(
      id: doc.id,
      provider: doc['Provider'],
      limitAmount: (doc['Limit_Amount'] as num).toDouble(),
      currency: doc['Currency'],
      typeId: doc['Type_Id'],
      limits: doc['Limits'] != null ? doc['Limits'].map<Limit>((limit) => Limit(
        monthYear: limit['Month_Year'],
        limit: (limit['Limit'] as num).toDouble(),
      )).toList() : null,
      installments: doc['Installments'] != null ? doc['Installments'].map<Installment>((installment) => Installment(
        name: installment['Name'],
        amount: (installment['Amount'] as num).toDouble(),
        month: installment['Month'],
        transactionDate: installment['Transaction_Date'],
        category: Category(
          id: installment['Category']['Id'],
          subId: installment['Category']['Sub_Id'],
        ),
        note: installment['Note'],
      )).toList() : null,
      dueDate: doc['Due_Date'],
      cutOffDate: doc['Cut_Off_Date'],
      icon: doc['Icon'],
      color: doc['Color'].toString(),
      isDeleted: doc['Is_Deleted'],
    );
  }
}