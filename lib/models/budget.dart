import 'package:cloud_firestore/cloud_firestore.dart';

class Categories {
  String _id;
  List<int>? _subId;
  
  Categories({
    required String id,
    required List<int>? subId,
  }) : _id = id,
  _subId = subId;

  String get id => _id;
  List<int>? get subId => _subId;

  set id(String value) { _id = value; }
  set subId(List<int>? value) { _subId = value; }
}

class Budget {
  String _id;
  double _amount;
  String _currency;
  String _name;
  List<String> _accountIds;
  List<Categories> _categories;
  String? _note;
  int _priorityTypeId;
  Timestamp _startDate;
  
  Budget({
    required String id,
    required double amount,
    required String currency,
    required String name,
    required List<String> accountIds,
    required List<Categories> categories,
    required String? note,
    required int priorityTypeId,
    required Timestamp startDate,
  }) : _id = id,
  _amount = amount,
  _currency = currency,
  _name = name,
  _accountIds = accountIds,
  _categories = categories,
  _priorityTypeId = priorityTypeId,
  _startDate = startDate,
  _note = note;

  String get id => _id;
  double get amount => _amount;
  String get currency => _currency;
  String get name => _name;
  List<String> get accountIds => _accountIds;
  List<Categories> get categories => _categories;
  int get priorityTypeId => _priorityTypeId;
  Timestamp get startDate => _startDate;
  String? get note => _note;

  set amount(double value) { _amount = value; }
  set currency(String value) { _currency = value; }
  set name(String value) { _name = value; }
  set accountIds(List<String> value) { _accountIds = value; }
  set categories(List<Categories> value) { _categories = value; }
  set priorityTypeId(int value) { _priorityTypeId = value; }
  set startDate(Timestamp value) { _startDate = value; }
  set note(String? value) { _note = value; }
}

class BudgetModel extends Budget {
  Timestamp _endDate;

  BudgetModel({
    required String id,
    required double amount,
    required String currency,
    required String name,
    required List<String> accountIds,
    required List<Categories> categories,
    required String? note,
    required int priorityTypeId,
    required Timestamp startDate,
    required Timestamp date,
    required Timestamp endDate,
  }) : _endDate = endDate,
  super(
    id: id,
    amount: amount,
    currency: currency,
    name: name,
    accountIds: accountIds,
    categories: categories,
    priorityTypeId: priorityTypeId,
    startDate: startDate,
    note: note
  );

  Timestamp get endDate => _endDate;
  set endDate(Timestamp value) { _endDate = value; }
}

class BudgetPlanModel extends Budget {
  bool _isActive;
  int _periodId;

  BudgetPlanModel({
    required String id,
    required double amount,
    required String currency,
    required String name,
    required List<String> accountIds,
    required List<Categories> categories,
    required String? note,
    required int priorityTypeId,
    required Timestamp startDate,
    required bool isActive,
    required int periodId,
  }) : _isActive = isActive,
  _periodId = periodId,
  super(
    id: id,
    amount: amount,
    currency: currency,
    name: name,
    accountIds: accountIds,
    categories: categories,
    priorityTypeId: priorityTypeId,
    startDate: startDate,
    note: note
  );

  bool get isActive => _isActive;
  int get periodId => _periodId;

  set isActive(bool value) { _isActive = value; }
  set periodId(int value) { _periodId = value; }
}