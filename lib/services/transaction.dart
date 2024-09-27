import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class TransactionService {
  Timestamp timestamp = Timestamp.now();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> createTransaction(String uid, String type, dynamic input) async {
    try {
      CollectionReference collection = FirebaseFirestore.instance.collection(type == 'transaction' ? 'Transactions' : type == 'template' ? 'Transaction_Templates' : 'Transaction_Plans');

      Map<String, dynamic> data = {
        'Amount': input.amount,
        'Category': input.category == null ?
          null :
          {
            'Id': input.category.id,
            'Sub_Id': input.category.subId
          },
        'Account_Id': {
          'Source': input.accountId.source,
          'Destination': input.accountId.destination
        },
        'Type_Id': input.typeId,
        'Fee': input.fee,
        'Note': input.note,
        'User': uid,
        'Updated_By': null,
        'Updated_At': null,
        'Created_By': uid,
        'Created_At': timestamp,
        'Is_Deleted': false,
      };

      if(type == 'transaction') {
        data['Date'] = input.date;
      }
      if(type == 'template') {
        data['Name'] = input.name;
      }
      if(type == 'plan') {
        data['Name'] = input.name;
        data['Is_Active'] = input.isActive;
        data['Frequency'] = {
          'Repeat': input.frequency.repeat,
          'Recurrence': {
            'Count': input.frequency.recurrence.count,
            'Time_Unit_Id': input.frequency.recurrence.timeUnitId,
            'Day': input.frequency.recurrence.day,
            'Week': input.frequency.recurrence.week,
            'Month': input.frequency.recurrence.month,
            'Year': input.frequency.recurrence.year,
          },
          'Start_Date': input.frequency.startDate,
          'End_Date': input.frequency.endDate,
        };
      }

      print("data");
      print(data);
      await collection.add(data);

      print({
        'success': true,
        'message': 'Sukses membuat ${type == 'transaction' ? 'transaksi' : type == 'template' ? 'templat transaksi' : 'transaksi berulang'}'
      });
      return {
        'success': true,
        'message': 'Sukses membuat ${type == 'transaction' ? 'transaksi' : type == 'template' ? 'templat transaksi' : 'transaksi berulang'}'
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

  Future<Map<String, dynamic>> updateTransaction(String uid, String id, String type, dynamic input) async {
    try {
      DocumentReference document = FirebaseFirestore.instance.collection(type == 'transaction' ? 'Transactions' : type == 'template' ? 'Transaction_Templates' : 'Transaction_Plans').doc(id);

      Map<String, dynamic> data = {
        'Amount': input.amount,
        'Category': input.category == null ?
          null :
          {
            'Id': input.category.id,
            'Sub_Id': input.category.subId
          },
        'Account_Id': {
          'Source': input.accountId.source,
          'Destination': input.accountId.destination
        },
        'Type_Id': input.typeId,
        'Fee': input.fee,
        'Note': input.note,
        'Updated_By': uid,
        'Updated_At': timestamp,
      };

      if(type == 'transaction') {
        data['Date'] = input.date;
      }
      if(type == 'template') {
        data['Name'] = input.name;
      }
      if(type == 'plan') {
        data['Name'] = input.name;
        data['Is_Active'] = input.isActive;
        data['Frequency'] = {
          'Repeat': input.frequency.repeat,
          'Recurrence': {
            'Count': input.frequency.recurrence.count,
            'Time_Unit_Id': input.frequency.recurrence.timeUnitId,
            'Day': input.frequency.recurrence.day,
            'Week': input.frequency.recurrence.week,
            'Month': input.frequency.recurrence.month,
            'Year': input.frequency.recurrence.year,
          },
          'Start_Date': input.frequency.startDate,
          'End_Date': input.frequency.endDate,
        };
      }

      await document.update(data);

      print({
        'success': true,
        'message': 'Sukses mengubah ${type == 'transaction' ? 'transaksi' : type == 'template' ? 'templat transaksi' : 'transaksi berulang'}'
      });
      return {
        'success': true,
        'message': 'Sukses mengubah ${type == 'transaction' ? 'transaksi' : type == 'template' ? 'templat transaksi' : 'transaksi berulang'}'
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
  
  Future<Map<String, dynamic>> deleteTransaction(String uid, String id, String type) async {
    try {
      DocumentReference document = FirebaseFirestore.instance.collection(type == 'transaction' ? 'Transactions' : type == 'template' ? 'Transaction_Templates' : 'Transaction_Plans').doc(id);

      await document.update({
        'Is_Deleted': true,
        'Updated_By': uid,
        'Updated_At': timestamp
      });

      print({
        'success': true,
        'message': 'Sukses menghapus ${type == 'transaction' ? 'transaksi' : type == 'template' ? 'templat transaksi' : 'transaksi berulang'}'
      });
      return {
        'success': true,
        'message': 'Sukses menghapus ${type == 'transaction' ? 'transaksi' : type == 'template' ? 'templat transaksi' : 'transaksi berulang'}'
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

  Future<Map<String, dynamic>> changeTransactionPlanActiveStatus(String uid, String id, bool previousValue) async {
    try {
      DocumentReference document = FirebaseFirestore.instance.collection('Transaction_Plans').doc(id);

      await document.update({
        'Is_Active': !previousValue,
        'Updated_By': uid,
        'Updated_At': timestamp
      });

      print({
        'success': true,
        'message': 'Sukses mengubah status aktif transaksi berulang'
      });
      return {
        'success': true,
        'message': 'Sukses mengubah status aktif transaksi berulang'
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