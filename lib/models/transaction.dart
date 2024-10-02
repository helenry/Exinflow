import "package:cloud_firestore/cloud_firestore.dart";
import "package:exinflow/models/common.dart";

class Account {
  String? _destination;
  String? _source;
  
  Account({
    required String? destination,
    required String? source,
  }) : _destination = destination,
  _source = source;

  String? get destination => _destination;
  String? get source => _source;

  set destination(String? value) { _destination = value; }
  set source(String? value) { _source = value; }
}

class Frequency {
  bool _repeat;
  Recurrence? _recurrence;
  Timestamp _startDate;
  
  Frequency({
    required bool repeat,
    required Recurrence? recurrence,
    required Timestamp startDate,
  }) : _repeat = repeat,
  _recurrence = recurrence,
  _startDate = startDate;

  bool get repeat => _repeat;
  Recurrence? get recurrence => _recurrence;
  Timestamp get startDate => _startDate;

  set repeat(bool value) { _repeat = value; }
  set recurrence(Recurrence? value) { _recurrence = value; }
  set startDate(Timestamp value) { _startDate = value; }
}

class Recurrence {
  int _count;
  int _timeUnitId;
  
  Recurrence({
    required int count,
    required int timeUnitId,
  }) : _count = count,
  _timeUnitId = timeUnitId;

  int get count => _count;
  int get timeUnitId => _timeUnitId;

  set count(int value) { _count = value; }
  set timeUnitId(int value) { _timeUnitId = value; }
}

class Transaction {
  String _id;
  double _amount;
  Category? _category;
  Account _accountId;
  int _typeId;
  double? _fee;
  String? _note;
  
  Transaction({
    required String id,
    required double amount,
    required Category? category,
    required Account accountId,
    required int typeId,
    required double? fee,
    required String? note,
  }) : _id = id,
  _amount = amount,
  _category = category,
  _accountId = accountId,
  _typeId = typeId,
  _fee = fee,
  _note = note;

  String get id => _id;
  double get amount => _amount;
  Category? get category => _category;
  Account get accountId => _accountId;
  int get typeId => _typeId;
  double? get fee => _fee;
  String? get note => _note;

  set amount(double value) { _amount = value; }
  set category(Category? value) { _category = value; }
  set accountId(Account value) { _accountId = value; }
  set typeId(int value) { _typeId = value; }
  set fee(double? value) { _fee = value; }
  set note(String? value) { _note = value; }
}

class TransactionModel extends Transaction {
  Timestamp _date;

  TransactionModel({
    required String id,
    required double amount,
    required Category? category,
    required Account accountId,
    required int typeId,
    required double? fee,
    required String? note,
    required Timestamp date,
  }) : _date = date,
  super(
    id: id,
    amount: amount,
    category: category,
    accountId: accountId,
    typeId: typeId,
    fee: fee,
    note: note,
  );

  Timestamp get date => _date;
  set date(Timestamp value) { _date = value; }
}

class TransactionTemplateModel extends Transaction {
  String _name;

  TransactionTemplateModel({
    required String id,
    required double amount,
    required Category? category,
    required Account accountId,
    required int typeId,
    required double? fee,
    required String? note,
    required String name,
  }) : _name = name,
  super(
    id: id,
    amount: amount,
    category: category,
    accountId: accountId,
    typeId: typeId,
    fee: fee,
    note: note,
  );

  String get name => _name;
  set name(String value) { _name = value; }
}

class TransactionPlanModel extends Transaction {
  bool _isActive;
  String _name;
  Frequency _frequency;

  TransactionPlanModel({
    required String id,
    required double amount,
    required Category? category,
    required Account accountId,
    required int typeId,
    required double? fee,
    required String? note,
    required bool isActive,
    required String name,
    required Frequency frequency,
  }) : _isActive = isActive,
  _name = name,
  _frequency = frequency,
  super(
    id: id,
    amount: amount,
    category: category,
    accountId: accountId,
    typeId: typeId,
    fee: fee,
    note: note,
  );

  bool get isActive => _isActive;
  String get name => _name;
  Frequency get frequency => _frequency;

  set isActive(bool value) { _isActive = value; }
  set name(String value) { _name = value; }
  set frequency(Frequency value) { _frequency = value; }
}