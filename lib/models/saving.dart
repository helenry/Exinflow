import "package:cloud_firestore/cloud_firestore.dart";
import "package:exinflow/models/common.dart";

class Record {
  double _amount;
  String _accountId;
  int _typeId;
  Timestamp _date;
  
  Record({
    required double amount,
    required String accountId,
    required int typeId,
    required Timestamp date,
  }) : _amount = amount,
  _accountId = accountId,
  _typeId = typeId,
  _date = date;

  double get amount => _amount;
  String get accountId => _accountId;
  int get typeId => _typeId;
  Timestamp get date => _date;

  set amount(double value) { _amount = value; }
  set accountId(String value) { _accountId = value; }
  set typeId(int value) { _typeId = value; }
  set date(Timestamp value) { _date = value; }
}

class SavingModel {
  String _id;
  double? _targetAmount;
  String _currency;
  Category _category;
  String _name;
  String? _note;
  Timestamp? _dueDate;
  List<Record>? _records;
  
  SavingModel({
    required String id,
    required double? targetAmount,
    required String currency,
    required Category category,
    required String name,
    required String? note,
    required Timestamp? dueDate,
    required List<Record>? records,
  }) : _id = id,
  _targetAmount = targetAmount,
  _currency = currency,
  _category = category,
  _name = name,
  _note = note,
  _dueDate = dueDate,
  _records = records;

  String get id => _id;
  double? get targetAmount => _targetAmount;
  String get currency => _currency;
  Category get category => _category;
  String get name => _name;
  String? get note => _note;
  Timestamp? get dueDate => _dueDate;
  List<Record>? get records => _records;

  set targetAmount(double? value) { _targetAmount = value; }
  set currency(String value) { _currency = value; }
  set category(Category value) { _category = value; }
  set name(String value) { _name = value; }
  set note(String? value) { _note = value; }
  set dueDate(Timestamp? value) { _dueDate = value; }

  factory SavingModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return SavingModel(
      id: doc.id,
      targetAmount: (doc['Target_Amount'] as num).toDouble(),
      currency: doc['Currency'],
      category: Category(
        id: doc['Category']['Id'],
        subId: doc['Category']['Sub_Id'],
      ),
      name: doc['Name'],
      note: doc['Note'],
      dueDate: doc['Due_Date'],
      records: doc['Records'] != null ? doc['Records'].map<Record>((record) => Record(
        amount: (record['Amount'] as num).toDouble(),
        accountId: record['Account_Id'],
        typeId: record['Type_Id'],
        date: record['Date'],
      )).toList() : null
    );
  }
}