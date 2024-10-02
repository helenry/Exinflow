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
          },
          'Start_Date': input.frequency.startDate,
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
            if(accountSource.limits == null || !accountSource.limits!.any((limit) => limit.monthYear == Timestamp.fromDate(DateTime(input.date.toDate().toUtc().add(Duration(hours: 7)).year, input.date.toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= accountSource.cutOffDate ? 1 : 2), 1)))) { // buat baru
              result = await creditService.createMonthlyLimit(uid, accountSource.id, Limit(monthYear: Timestamp.fromDate(DateTime(input.date.toDate().toUtc().add(Duration(hours: 7)).year, input.date.toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= accountSource.cutOffDate ? 1 : 2), 1)), limit: accountSource.limitAmount - input.amount));
            } else { // update
              result = await creditService.updateMonthlyLimit(uid, accountSource.id, accountSource.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(input.date.toDate().toUtc().add(Duration(hours: 7)).year, input.date.toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= accountSource.cutOffDate ? 1 : 2), 1))), accountSource.limits![accountSource.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(input.date.toDate().toUtc().add(Duration(hours: 7)).year, input.date.toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= accountSource.cutOffDate ? 1 : 2), 1)))].limit - input.amount);
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
      
      if(result['message'] == '') {
        result = {
          'success': true,
          'message': ''
        };
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
          },
          'Start_Date': input.frequency.startDate,
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
              CreditModel oldAccount = creditController.credits.firstWhere((credit) => credit.id == snapshot['Account_Id']['Source']);
              AccountModel newAccount = accountController.accounts.firstWhere((account) => account.id == input.accountId.source);

              // tambah limit kredit bulan lama dgn jumlah lama
              Map<String, dynamic> creditResult = await creditService.updateMonthlyLimit(uid, oldAccount.id, oldAccount.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).year, snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).month + (snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).day <= oldAccount.cutOffDate ? 1 : 2), 1))), oldAccount.limits![oldAccount.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).year, snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).month + (snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).day <= oldAccount.cutOffDate ? 1 : 2), 1)))].limit + snapshot['Amount']);
              // kurangi jumlah di akun baru dgn jumlah baru
              Map<String, dynamic> accountResult = await accountService.updateAccount(uid, newAccount.id, AccountModel(
                id: '',
                name: newAccount.name,
                amount: newAccount.amount - input.amount,
                currency: newAccount.currency,
                icon: newAccount.icon,
                color: newAccount.color,
                isDeleted: false
              ));

              if(creditResult['success'] == true && accountResult['success'] == true) {
                result = {
                  'success': accountResult['success'],
                  'message': accountResult['message']
                };
              } else {
                result = {
                  'success': false,
                  'message': 'Gagal mengubah akun'
                };
              }
            } else if(creditController.credits.any((credit) => credit.id == input.accountId.source) && accountController.accounts.any((account) => account.id == snapshot['Account_Id']['Source'])) { // akun > kredit
              AccountModel oldAccount = accountController.accounts.firstWhere((account) => account.id == snapshot['Account_Id']['Source']);
              CreditModel newAccount = creditController.credits.firstWhere((credit) => credit.id == input.accountId.source);

              // tambah jumlah di akun lama dgn jumlah lama
              Map<String, dynamic> accountResult = await accountService.updateAccount(uid, oldAccount.id, AccountModel(
                id: '',
                name: oldAccount.name,
                amount: oldAccount.amount + snapshot['Amount'],
                currency: oldAccount.currency,
                icon: oldAccount.icon,
                color: oldAccount.color,
                isDeleted: false
              ));
              // buat/cari limit kredit, kurangi limit kredit dgn jumlah baru
              Map<String, dynamic> creditResult = {};
              if(newAccount.limits == null || !newAccount.limits!.any((limit) => limit.monthYear == Timestamp.fromDate(DateTime(input.date.toDate().toUtc().add(Duration(hours: 7)).year, input.date.toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= newAccount.cutOffDate ? 1 : 2), 1)))) {
                creditResult = await creditService.createMonthlyLimit(uid, newAccount.id, Limit(monthYear: Timestamp.fromDate(DateTime(input.date.toDate().toUtc().add(Duration(hours: 7)).year, input.date.toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= newAccount.cutOffDate ? 1 : 2), 1)), limit: newAccount.limitAmount - input.amount));
              } else {
                creditResult = await creditService.updateMonthlyLimit(uid, newAccount.id, newAccount.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(input.date.toDate().toUtc().add(Duration(hours: 7)).year, input.date.toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= newAccount.cutOffDate ? 1 : 2), 1))), newAccount.limits![newAccount.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(input.date.toDate().toUtc().add(Duration(hours: 7)).year, input.date.toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= newAccount.cutOffDate ? 1 : 2), 1)))].limit - input.amount);
              }

              if(accountResult['success'] == true && creditResult['success'] == true) {
                result = {
                  'success': creditResult['success'],
                  'message': creditResult['message']
                };
              } else {
                result = {
                  'success': false,
                  'message': 'Gagal mengubah akun'
                };
              }
            } else if(creditController.credits.any((credit) => credit.id == input.accountId.source) && creditController.credits.any((credit) => credit.id == snapshot['Account_Id']['Source'])) { // kredit > kredit
              CreditModel oldAccount = creditController.credits.firstWhere((credit) => credit.id == snapshot['Account_Id']['Source']);
              CreditModel newAccount = creditController.credits.firstWhere((credit) => credit.id == input.accountId.source);

              // tambah limit kredit lama dgn jumlah lama
              Map<String, dynamic> oldResult = await creditService.updateMonthlyLimit(uid, oldAccount.id, oldAccount.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).year, snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).month + (snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).day <= oldAccount.cutOffDate ? 1 : 2), 1))), oldAccount.limits![oldAccount.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).year, snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).month + (snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).day <= oldAccount.cutOffDate ? 1 : 2), 1)))].limit + snapshot['Amount']);
              // buat/cari limit kredit baru, kurangi limit kredit dgn jumlah baru
              Map<String, dynamic> newResult = {};
              if(newAccount.limits == null || !newAccount.limits!.any((limit) => limit.monthYear == Timestamp.fromDate(DateTime(input.date.toDate().toUtc().add(Duration(hours: 7)).year, input.date.toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= newAccount.cutOffDate ? 1 : 2), 1)))) {
                newResult = await creditService.createMonthlyLimit(uid, newAccount.id, Limit(monthYear: Timestamp.fromDate(DateTime(input.date.toDate().toUtc().add(Duration(hours: 7)).year, input.date.toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= newAccount.cutOffDate ? 1 : 2), 1)), limit: newAccount.limitAmount - input.amount));
              } else {
                newResult = await creditService.updateMonthlyLimit(uid, newAccount.id, newAccount.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(input.date.toDate().toUtc().add(Duration(hours: 7)).year, input.date.toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= newAccount.cutOffDate ? 1 : 2), 1))), newAccount.limits![newAccount.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(input.date.toDate().toUtc().add(Duration(hours: 7)).year, input.date.toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= newAccount.cutOffDate ? 1 : 2), 1)))].limit - input.amount);
              }

              if(oldResult['success'] == true && newResult['success'] == true) {
                result = {
                  'success': newResult['success'],
                  'message': newResult['message']
                };
              } else {
                result = {
                  'success': false,
                  'message': 'Gagal mengubah akun'
                };
              }
            } else { // akun > akun
              AccountModel oldAccount = accountController.accounts.firstWhere((account) => account.id == (input.typeId == 0 ? snapshot['Account_Id']['Source'] : snapshot['Account_Id']['Destination']));
              AccountModel newAccount = accountController.accounts.firstWhere((account) => account.id == (input.typeId == 0 ? input.accountId.source : input.accountId.destination));

              // tambah jumlah di akun lama dgn jumlah lama
              Map<String, dynamic> oldResult = await accountService.updateAccount(uid, oldAccount.id, AccountModel(
                id: '',
                name: oldAccount.name,
                amount: oldAccount.amount + snapshot['Amount'],
                currency: oldAccount.currency,
                icon: oldAccount.icon,
                color: oldAccount.color,
                isDeleted: false
              ));
              // kurangi jumlah di akun baru dgn jumlah baru
              Map<String, dynamic> newResult = await accountService.updateAccount(uid, newAccount.id, AccountModel(
                id: '',
                name: newAccount.name,
                amount: newAccount.amount - input.amount,
                currency: newAccount.currency,
                icon: newAccount.icon,
                color: newAccount.color,
                isDeleted: false
              ));

              if(oldResult['success'] == true && newResult['success'] == true) {
                result = {
                  'success': newResult['success'],
                  'message': newResult['message']
                };
              } else {
                result = {
                  'success': false,
                  'message': 'Gagal mengubah akun'
                };
              }
            }
          } else if(input.typeId == 2) {
            AccountModel oldSourceAccount = accountController.accounts.firstWhere((account) => account.id == snapshot['Account_Id']['Source']);
            AccountModel newSourceAccount = accountController.accounts.firstWhere((account) => account.id == input.accountId.source);
            AccountModel oldDestinationAccount = accountController.accounts.firstWhere((account) => account.id == snapshot['Account_Id']['Destination']);
            AccountModel newDestinationAccount = accountController.accounts.firstWhere((account) => account.id == input.accountId.destination);

            // tambah jumlah di akun source lama dgn jumlah lama dan fee lama
            Map<String, dynamic> oldSourceResult = await accountService.updateAccount(uid, oldSourceAccount.id, AccountModel(
              id: '',
              name: oldSourceAccount.name,
              amount: oldSourceAccount.amount + snapshot['Amount'] + (snapshot['Fee'] == null ? 0 : snapshot['Fee']),
              currency: oldSourceAccount.currency,
              icon: oldSourceAccount.icon,
              color: oldSourceAccount.color,
              isDeleted: false
            ));
            // kurangi jumlah di akun source baru dgn jumlah baru dan fee baru
            Map<String, dynamic> newSourceResult = await accountService.updateAccount(uid, newSourceAccount.id, AccountModel(
              id: '',
              name: newSourceAccount.name,
              amount: newSourceAccount.amount - input.amount - (input.fee == null ? 0 : input.fee),
              currency: newSourceAccount.currency,
              icon: newSourceAccount.icon,
              color: newSourceAccount.color,
              isDeleted: false
            ));
            // kurangi jumlah di akun destination lama dgn jumlah lama dan fee lama
            Map<String, dynamic> oldDestinationResult = await accountService.updateAccount(uid, oldDestinationAccount.id, AccountModel(
              id: '',
              name: oldDestinationAccount.name,
              amount: oldDestinationAccount.amount - snapshot['Amount'] - (snapshot['Fee'] == null ? 0 : snapshot['Fee']),
              currency: oldDestinationAccount.currency,
              icon: oldDestinationAccount.icon,
              color: oldDestinationAccount.color,
              isDeleted: false
            ));
            // tambah jumlah di akun destination baru dgn jumlah baru dan fee baru
            Map<String, dynamic> newDestinationResult = await accountService.updateAccount(uid, newDestinationAccount.id, AccountModel(
              id: '',
              name: newDestinationAccount.name,
              amount: newDestinationAccount.amount + input.amount + (input.fee == null ? 0 : input.fee),
              currency: newDestinationAccount.currency,
              icon: newDestinationAccount.icon,
              color: newDestinationAccount.color,
              isDeleted: false
            ));

            if(oldSourceResult['success'] == true && newSourceResult['success'] == true && oldDestinationResult['success'] == true && newDestinationResult['success'] == true) {
              result = {
                'success': newDestinationResult['success'],
                'message': newDestinationResult['message']
              };
            } else {
              result = {
                'success': false,
                'message': 'Gagal mengubah akun'
              };
            }
          }
        } else { // same account/credit
          if(input.typeId == 0 || input.typeId == 1) {
            if(creditController.credits.any((credit) => credit.id == input.accountId.source) && creditController.credits.any((credit) => credit.id == snapshot['Account_Id']['Source'])) { // is credit
              if((input.date.toDate().toUtc().add(Duration(hours: 7)).year != snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).year) || (input.date.toDate().toUtc().add(Duration(hours: 7)).month != snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).month)) { // different month or year
                CreditModel credit = creditController.credits.firstWhere((credit) => credit.id == snapshot['Account_Id']['Source']);

                // tambah limit lama dgn jumlah lama
                Map<String, dynamic> oldResult = await creditService.updateMonthlyLimit(uid, credit.id, credit.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).year, snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).month + (snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).day <= credit.cutOffDate ? 1 : 2), 1))), credit.limits![credit.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).year, snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).month + (snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).day <= credit.cutOffDate ? 1 : 2), 1)))].limit + snapshot['Amount']);
                // buat/cari limit baru, kurangi limit dgn jumlah baru
                Map<String, dynamic> newResult = {};
                if(credit.limits == null || !credit.limits!.any((limit) => limit.monthYear == Timestamp.fromDate(DateTime(input.date.toDate().toUtc().add(Duration(hours: 7)).year, input.date.toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= credit.cutOffDate ? 1 : 2), 1)))) {
                  newResult = await creditService.createMonthlyLimit(uid, credit.id, Limit(monthYear: Timestamp.fromDate(DateTime(input.date.toDate().toUtc().add(Duration(hours: 7)).year, input.date.toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= credit.cutOffDate ? 1 : 2), 1)), limit: credit.limitAmount - input.amount));
                } else {
                  newResult = await creditService.updateMonthlyLimit(uid, credit.id, credit.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(input.date.toDate().toUtc().add(Duration(hours: 7)).year, input.date.toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= credit.cutOffDate ? 1 : 2), 1))), credit.limits![credit.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(input.date.toDate().toUtc().add(Duration(hours: 7)).year, input.date.toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= credit.cutOffDate ? 1 : 2), 1)))].limit - input.amount);
                }

                if(oldResult['success'] == true && newResult['success'] == true) {
                  result = {
                    'success': newResult['success'],
                    'message': newResult['message']
                  };
                } else {
                  result = {
                    'success': false,
                    'message': 'Gagal mengubah akun'
                  };
                }
              } else { // same month and year
                CreditModel credit = creditController.credits.firstWhere((credit) => credit.id == snapshot['Account_Id']['Source']);

                if((input.date.toDate().toUtc().add(Duration(hours: 7)).day <= credit.cutOffDate && snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).day <= credit.cutOffDate) || (input.date.toDate().toUtc().add(Duration(hours: 7)).day > credit.cutOffDate && snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).day > credit.cutOffDate)) { // same before/after cut off date
                  if(input.amount != snapshot['Amount']) { // different amount
                    // ubah limit
                    result = await creditService.updateMonthlyLimit(uid, credit.id, credit.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).year, snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= credit.cutOffDate ? 1 : 2), 1))), credit.limits![credit.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).year, snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= credit.cutOffDate ? 1 : 2), 1)))].limit + snapshot['Amount'] - input.amount);
                  }
                } else { // different before/after cut off date
                  // tambah limit lama dgn jumlah lama
                  Map<String, dynamic> oldResult = await creditService.updateMonthlyLimit(uid, credit.id, credit.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).year, snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).month + (snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).day <= credit.cutOffDate ? 1 : 2), 1))), credit.limits![credit.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).year, snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).month + (snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).day <= credit.cutOffDate ? 1 : 2), 1)))].limit + snapshot['Amount']);
                  // buat/cari limit baru, kurangi limit dgn jumlah baru
                  Map<String, dynamic> newResult = {};
                  if(credit.limits == null || !credit.limits!.any((limit) => limit.monthYear == Timestamp.fromDate(DateTime(input.date.toDate().toUtc().add(Duration(hours: 7)).year, input.date.toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= credit.cutOffDate ? 1 : 2), 1)))) {
                    newResult = await creditService.createMonthlyLimit(uid, credit.id, Limit(monthYear: Timestamp.fromDate(DateTime(input.date.toDate().toUtc().add(Duration(hours: 7)).year, input.date.toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= credit.cutOffDate ? 1 : 2), 1)), limit: credit.limitAmount - input.amount));
                  } else {
                    newResult = await creditService.updateMonthlyLimit(uid, credit.id, credit.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(input.date.toDate().toUtc().add(Duration(hours: 7)).year, input.date.toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= credit.cutOffDate ? 1 : 2), 1))), credit.limits![credit.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(input.date.toDate().toUtc().add(Duration(hours: 7)).year, input.date.toDate().toUtc().add(Duration(hours: 7)).month + (input.date.toDate().toUtc().add(Duration(hours: 7)).day <= credit.cutOffDate ? 1 : 2), 1)))].limit - input.amount);
                  }

                  if(oldResult['success'] == true && newResult['success'] == true) {
                    result = {
                      'success': newResult['success'],
                      'message': newResult['message']
                    };
                  } else {
                    result = {
                      'success': false,
                      'message': 'Gagal mengubah akun'
                    };
                  }
                }
              }
            } else { // is account
              if(input.amount != snapshot['Amount']) { // different amount
                AccountModel account = accountController.accounts.firstWhere((account) => account.id == (input.typeId == 0 ? snapshot['Account_Id']['Source'] : snapshot['Account_Id']['Destination']));

                // ubah amount akun
                result = await accountService.updateAccount(uid, account.id, AccountModel(
                  id: '',
                  name: account.name,
                  amount: account.amount + (input.typeId == 0 ? snapshot['Amount'] : input.amount) - (input.typeId == 0 ? input.amount : snapshot['Amount']),
                  currency: account.currency,
                  icon: account.icon,
                  color: account.color,
                  isDeleted: false
                ));
              }
            }
          } else if(input.typeId == 2) {
            if(input.amount != snapshot['Amount'] || input.fee != snapshot['Fee']) { // different amount or fee
              AccountModel sourceAccount = accountController.accounts.firstWhere((account) => account.id == snapshot['Account_Id']['Source']);
              AccountModel destinationAccount = accountController.accounts.firstWhere((account) => account.id == snapshot['Account_Id']['Destination']);

              // ubah amount akun source
              Map<String, dynamic> sourceResult = await accountService.updateAccount(uid, sourceAccount.id, AccountModel(
                id: '',
                name: sourceAccount.name,
                amount: sourceAccount.amount + snapshot['Amount'] - input.amount,
                currency: sourceAccount.currency,
                icon: sourceAccount.icon,
                color: sourceAccount.color,
                isDeleted: false
              ));
              // ubah amount akun destination
              Map<String, dynamic> destinationResult = await accountService.updateAccount(uid, destinationAccount.id, AccountModel(
                id: '',
                name: destinationAccount.name,
                amount: destinationAccount.amount + input.amount - snapshot['Amount'],
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
        }
      }

      if(result['message'] == '') {
        result = {
          'success': true,
          'message': ''
        };
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
            result = await creditService.updateMonthlyLimit(uid, accountSource.id, accountSource.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).year, snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).month, 1))), accountSource.limits![accountSource.limits!.indexWhere((limit) => limit.monthYear == Timestamp.fromDate(DateTime(snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).year, snapshot['Date'].toDate().toUtc().add(Duration(hours: 7)).month, 1)))].limit + snapshot['Amount']);
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