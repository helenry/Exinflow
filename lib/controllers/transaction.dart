import 'package:exinflow/models/transaction.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionController extends GetxController {
  TransactionModel? transaction;
  TransactionTemplateModel? transactionTemplate;
  TransactionPlanModel? transactionPlan;

  void setTransaction(TransactionModel selected) {
    transaction = selected;
  }
  void setTransactionTemplate(TransactionTemplateModel selected) {
    transactionTemplate = selected;
  }
  void setTransactionPlan(TransactionPlanModel selected) {
    transactionPlan = selected;
  }
}