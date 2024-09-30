import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exinflow/models/account.dart';
import 'package:exinflow/models/credit.dart';
import 'package:get/get.dart';
import 'package:exinflow/controllers/account.dart';
import 'package:exinflow/controllers/credit.dart';
import 'package:exinflow/services/account.dart';
import 'package:exinflow/services/credit.dart';
import 'package:exinflow/services/currency.dart';

class TransactionService {
  Timestamp timestamp = Timestamp.now();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final AccountController accountController = Get.find<AccountController>();
  final CreditController creditController = Get.find<CreditController>();
  final AccountService accountService = AccountService();
  final CreditService creditService = CreditService();
  final CurrencyService currencyService = CurrencyService();

  Future<Map<String, dynamic>> createTransaction(String uid, String type, dynamic input) async {
    print('INPUT');
    print(input);
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

      Map<String, dynamic> result = {
        'success': false,
        'message': ''
      };

      if(type == 'transaction') {
        if(input.typeId == 0 || input.typeId == 1) {
          dynamic accountSource;
          try {
            accountSource = accountController.accounts.firstWhere((account) => account.id == (input.typeId == 0 ? input.accountId.source : input.accountId.destination));
          } catch (e) {
            try {
              accountSource = creditController.credits.firstWhere((credit) => credit.id == (input.typeId == 0 ? input.accountId.source : input.accountId.destination));
            } catch (e) {
              print('Error: $e');
            }
          }

          if(accountSource is AccountModel) {
            result = await accountService.updateAccount(uid, accountSource.id, AccountModel(
              id: '',
              name: accountSource.name,
              amount: input.typeId == 0 ? accountSource.amount - input.amount : accountSource.amount + input.amount,
              currency: accountSource.currency,
              icon: accountSource.icon,
              color: accountSource.color,
              isDeleted: false
            ));
          } else if(accountSource is CreditModel) {
            if(accountSource.limits == null || !accountSource.limits!.any((limit) => limit.monthYear == Timestamp.fromDate(DateTime(input.date.toDate().year, input.date.toDate().month, 1)))) {
              result = await creditService.createMonthlyLimit(uid, accountSource.id, Limit(monthYear: Timestamp.fromDate(DateTime(input.date.toDate().year, input.date.toDate().month, 1)), limit: accountSource.limitAmount - input.amount));
            } else {
              result = await creditService.updateMonthlyLimit(uid, accountSource.id, accountSource.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(input.date.toDate().year, input.date.toDate().month, 1))), accountSource.limits![accountSource.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(input.date.toDate().year, input.date.toDate().month, 1)))].limit - input.amount);
            }
          }
        } else if(input.typeId == 2) {
          AccountModel sourceAccount = accountController.accounts.firstWhere((account) => account.id == input.accountId.source);
          AccountModel destinationAccount = accountController.accounts.firstWhere((account) => account.id == input.accountId.destination);

          Map<String, dynamic> sourceResult = await accountService.updateAccount(uid, sourceAccount.id, AccountModel(
            id: '',
            name: sourceAccount.name,
            amount: sourceAccount.amount - input.amount - (input.fee == null ? 0 : input.fee),
            currency: sourceAccount.currency,
            icon: sourceAccount.icon,
            color: sourceAccount.color,
            isDeleted: false
          ));

          dynamic currency = {};
          if(sourceAccount.currency != destinationAccount.currency) {
            currency = await currencyService.conversionRate(destinationAccount.currency, [sourceAccount.currency], 'now');
          }
          Map<String, dynamic> destinationResult = await accountService.updateAccount(uid, destinationAccount.id, AccountModel(
            id: '',
            name: destinationAccount.name,
            amount: destinationAccount.amount + (sourceAccount.currency != destinationAccount.currency ? (input.amount * currency[sourceAccount.currency]) : input.amount),
            currency: destinationAccount.currency,
            icon: destinationAccount.icon,
            color: destinationAccount.color,
            isDeleted: false
          ));

          if(sourceResult['success'] == true && destinationResult['success'] == true) {
            result = {
              'success': destinationResult['success'],
              'message': destinationResult['message']
            };
          } else {
            result = {
              'success': false,
              'message': 'Gagal mengubah akun'
            };
          }
        }
      }

      if(result['success']) {
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
      } else {
        print({
          'success': result['success'],
          'message': result['message']
        });
        return {
          'success': result['success'],
          'message': result['message']
        };
      }
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
      DocumentSnapshot snapshot = await document.get();

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

      Map<String, dynamic> result = {
        'success': true,
        'message': ''
      };

      if(type == 'transaction') {
        if((input.typeId == 0 && (input.accountId.source != snapshot['Account_Id']['Source'])) || (input.typeId == 1 && (input.accountId.destination != snapshot['Account_Id']['Destination'])) || (input.typeId == 2 && (input.accountId.source != snapshot['Account_Id']['Source'] || input.accountId.destination != snapshot['Account_Id']['Destination']))) { // different account/credit
          if(input.typeId == 0 || input.typeId == 1) {
            if(accountController.accounts.any((account) => account.id == input.accountId.source) && creditController.credits.any((credit) => credit.id == snapshot['Account_Id']['Source'])) { // kredit > akun
              CreditModel oldAccount = creditController.credits.firstWhere((credit) => credit.id == (input.typeId == 0 ? snapshot['Account_Id']['Source'] : snapshot['Account_Id']['Destination']));
              AccountModel newAccount = accountController.accounts.firstWhere((account) => account.id == (input.typeId == 0 ? input.accountId.source : input.accountId.destination));

              // tambah limit kredit bulan lama dgn jumlah lama
              // kurangi jumlah di akun baru dgn jumlah baru
            } else if(creditController.credits.any((credit) => credit.id == input.accountId.source) && accountController.accounts.any((account) => account.id == snapshot['Account_Id']['Source'])) { // akun > kredit
              AccountModel oldAccount = accountController.accounts.firstWhere((account) => account.id == (input.typeId == 0 ? snapshot['Account_Id']['Source'] : snapshot['Account_Id']['Destination']));
              CreditModel newAccount = creditController.credits.firstWhere((credit) => credit.id == (input.typeId == 0 ? input.accountId.source : input.accountId.destination));

              // tambah jumlah di akun lama dgn jumlah lama
              // buat/cari limit kredit, kurangi limit kredit dgn jumlah baru
            } else if(creditController.credits.any((credit) => credit.id == input.accountId.source) && creditController.credits.any((credit) => credit.id == snapshot['Account_Id']['Source'])) { // kredit > kredit
              CreditModel oldAccount = creditController.credits.firstWhere((credit) => credit.id == (input.typeId == 0 ? snapshot['Account_Id']['Source'] : snapshot['Account_Id']['Destination']));
              CreditModel newAccount = creditController.credits.firstWhere((credit) => credit.id == (input.typeId == 0 ? input.accountId.source : input.accountId.destination));

              // kurangi limit kredit lama dgn jumlah lama
              // buat/cari limit kredit baru, kurangi limit kredit dgn jumlah baru
            } else { // akun > akun
              AccountModel oldAccount = accountController.accounts.firstWhere((account) => account.id == (input.typeId == 0 ? snapshot['Account_Id']['Source'] : snapshot['Account_Id']['Destination']));
              AccountModel newAccount = accountController.accounts.firstWhere((account) => account.id == (input.typeId == 0 ? input.accountId.source : input.accountId.destination));

              // tambah jumlah di akun lama dgn jumlah lama
              // kurangi jumlah di akun baru dgn jumlah baru
            }
          } else if(input.typeId == 2) {
            AccountModel oldSourceAccount = accountController.accounts.firstWhere((account) => account.id == snapshot['Account_Id']['Source']);
            AccountModel newSourceAccount = accountController.accounts.firstWhere((account) => account.id == input.accountId.source);
            AccountModel oldDestinationAccount = accountController.accounts.firstWhere((account) => account.id == snapshot['Account_Id']['Destination']);
            AccountModel newDestinationAccount = accountController.accounts.firstWhere((account) => account.id == input.accountId.destination);

            // tambah jumlah di akun source lama dgn jumlah lama dan fee lama
            // kurangi jumlah di akun source baru dgn jumlah baru dan fee baru
            // kurangi jumlah di akun destination lama dgn jumlah lama dan fee lama
            // tambah jumlah di akun destination baru dgn jumlah baru dan fee baru
          }
        } else { // same account/credit
          if(input.typeId == 0 || input.typeId == 1) {
            if(creditController.credits.any((credit) => credit.id == input.accountId.source) && creditController.credits.any((credit) => credit.id == snapshot['Account_Id']['Source'])) { // is credit
              if((input.date.toDate().year != snapshot['Date'].toDate().year) || (input.date.toDate().month != snapshot['Date'].toDate().month)) { // different month and year
                // tambah limit lama dgn jumlah lama
                // buat/cari limit baru, kurangi limit dgn jumlah baru
              } else { // same month and year
                if(input.amount != snapshot['Amount']) { // different amount
                  // ubah limit
                }
              }
            } else { // is account
              if(input.amount != snapshot['Amount']) { // different amount
                // ubah amount akun
              }
            }
          } else if(input.typeId == 2) {
            if(input.amount != snapshot['Amount'] || input.fee != snapshot['Fee']) { // different amount or fee
                // ubah amount akun source
                // ubah amount akun destination
            }
          }
        }
      }

      if(result['success']) {
        print("data");
        print(data);
        await document.update(data);

        print({
          'success': true,
          'message': 'Sukses mengubah ${type == 'transaction' ? 'transaksi' : type == 'template' ? 'templat transaksi' : 'transaksi berulang'}'
        });
        return {
          'success': true,
          'message': 'Sukses mengubah ${type == 'transaction' ? 'transaksi' : type == 'template' ? 'templat transaksi' : 'transaksi berulang'}'
        };
      } else {
        print({
          'success': result['success'],
          'message': result['message']
        });
        return {
          'success': result['success'],
          'message': result['message']
        };
      }
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
      DocumentSnapshot snapshot = await document.get();

      Map<String, dynamic> result = {
        'success': false,
        'message': ''
      };

      if(type == 'transaction') {
        if(snapshot['Type_Id'] == 0 || snapshot['Type_Id'] == 1) {
          dynamic accountSource;
          try {
            accountSource = accountController.accounts.firstWhere((account) => account.id == (snapshot['Type_Id'] == 0 ? snapshot['Account_Id']['Source'] : snapshot['Account_Id']['Destination']));
          } catch (e) {
            try {
              accountSource = creditController.credits.firstWhere((credit) => credit.id == (snapshot['Type_Id'] == 0 ? snapshot['Account_Id']['Source'] : snapshot['Account_Id']['Destination']));
            } catch (e) {
              print('Error: $e');
            }
          }

          if(accountSource is AccountModel) {
            result = await accountService.updateAccount(uid, accountSource.id, AccountModel(
              id: '',
              name: accountSource.name,
              amount: snapshot['Type_Id'] == 0 ? accountSource.amount + snapshot['Amount'] : accountSource.amount - snapshot['Amount'],
              currency: accountSource.currency,
              icon: accountSource.icon,
              color: accountSource.color,
              isDeleted: false
            ));
          } else if(accountSource is CreditModel) {
            result = await creditService.updateMonthlyLimit(uid, accountSource.id, accountSource.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(snapshot['Date'].toDate().year, snapshot['Date'].toDate().month, 1))), accountSource.limits![accountSource.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(snapshot['Date'].toDate().year, snapshot['Date'].toDate().month, 1)))].limit + snapshot['Amount']);
          }
        } else if(snapshot['Type_Id'] == 2) {
          AccountModel sourceAccount = accountController.accounts.firstWhere((account) => account.id == snapshot['Account_Id']['Source']);
          AccountModel destinationAccount = accountController.accounts.firstWhere((account) => account.id == snapshot['Account_Id']['Destination']);

          Map<String, dynamic> sourceResult = await accountService.updateAccount(uid, sourceAccount.id, AccountModel(
            id: '',
            name: sourceAccount.name,
            amount: sourceAccount.amount + snapshot['Amount'] + (snapshot['Fee'] == null ? 0 : snapshot['Fee']),
            currency: sourceAccount.currency,
            icon: sourceAccount.icon,
            color: sourceAccount.color,
            isDeleted: false
          ));

          dynamic currency = {};
          if(sourceAccount.currency != destinationAccount.currency) {
            currency = await currencyService.conversionRate(destinationAccount.currency, [sourceAccount.currency], 'now');
          }
          Map<String, dynamic> destinationResult = await accountService.updateAccount(uid, destinationAccount.id, AccountModel(
            id: '',
            name: destinationAccount.name,
            amount: destinationAccount.amount + (sourceAccount.currency != destinationAccount.currency ? (snapshot['Amount'] * currency[sourceAccount.currency]) : snapshot['Amount']),
            currency: destinationAccount.currency,
            icon: destinationAccount.icon,
            color: destinationAccount.color,
            isDeleted: false
          ));

          if(sourceResult['success'] == true && destinationResult['success'] == true) {
            result = {
              'success': destinationResult['success'],
              'message': destinationResult['message']
            };
          } else {
            result = {
              'success': false,
              'message': 'Gagal mengubah akun'
            };
          }
        }
      }

      if(result['success']) {
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
      } else {
        print({
          'success': result['success'],
          'message': result['message']
        });
        return {
          'success': result['success'],
          'message': result['message']
        };
      }
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