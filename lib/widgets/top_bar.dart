import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:exinflow/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exinflow/widgets/alert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:exinflow/controllers/account.dart';
import 'package:exinflow/controllers/category.dart';
import 'package:exinflow/controllers/credit.dart';
import 'package:exinflow/controllers/transaction.dart';
import 'package:exinflow/controllers/saving.dart';
import 'package:exinflow/controllers/icon.dart';
import 'package:exinflow/controllers/color.dart';

import 'package:exinflow/services/account.dart';
import 'package:exinflow/services/category.dart';
import 'package:exinflow/services/transaction.dart';
import 'package:exinflow/services/credit.dart';
import 'package:exinflow/services/saving.dart';

import 'package:exinflow/models/account.dart';
import 'package:exinflow/models/category.dart';
import 'package:exinflow/models/transaction.dart';
import 'package:exinflow/models/credit.dart';
import 'package:exinflow/models/saving.dart';
import 'package:exinflow/models/common.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final user = FirebaseAuth.instance.currentUser;
  final AccountService accountService = AccountService();
  final CategoryService categoryService = CategoryService();
  final TransactionService transactionService = TransactionService();
  final CreditService creditService = CreditService();
  final SavingService savingService = SavingService();

  final AccountController accountController = Get.find<AccountController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final TransactionController transactionController = Get.find<TransactionController>();
  final CreditController creditController = Get.find<CreditController>();
  final SavingController savingController = Get.find<SavingController>();
  final IconController iconController = Get.find<IconController>();
  final ColorController colorController = Get.find<ColorController>();

  final String id;
  final String title;
  final String menu;
  final String page;
  final String type;
  final String from;
  final String subtype;
  final int subIndex;
  final double height = kToolbarHeight;

  TopBar({Key? key, required this.id, required this.title, required this.menu, required this.page, required this.type, required this.from, required this.subtype, required this.subIndex}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(100),
      child: SafeArea(
        child: Container(
          height: 100,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  context.pop();
                  
                  if(type != 'edit' || (type == 'edit' && from == 'dots')) {
                    if(menu == "Akun") {
                      accountController.setAccount(
                        AccountModel(
                          id: '',
                          name: '',
                          amount: 0,
                          currency: '',
                          icon: '',
                          color: '',
                          isDeleted: false
                        )
                      );
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  shape: CircleBorder(),
                  side: BorderSide(width: 1, color: mainBlue),
                  padding: EdgeInsets.zero,
                  minimumSize: Size(40, 40),
                ),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: mainBlue,
                  size: 40
                ),
              ),
        
              Padding(
                padding: EdgeInsets.only(
                  left: page == 'All' ? 0 : type == 'view' ? 52 : 0,
                  right: page == 'All' || type == 'view' ? 0 : 47
                ),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: small,
                      fontFamily: "Open Sans",
                      fontWeight: FontWeight.w600,
                      color: greyMinusOne
                    ),
                  ),
                ),
              ),
        
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if(page == 'All')
                    OutlinedButton(
                      onPressed: (menu == 'Kredit' && subtype == 'bill') ? null : () {
                          print("IMP: menu");
                          print(menu);
                          print(subtype);
                        if(menu == "Akun") {
                          context.push('/manage/accounts/account');
                        }
                        if(menu == "Kategori") {
                          if(subtype == 'category') {
                            context.push('/manage/categories/category');
                          }
                          if(subtype == 'subcategory') {
                            context.push('/manage/categories/category/$id/subcategory');
                          }
                        }
                        if(menu == "Transaksi") {
                          context.push('/manage/transactions/$subtype');
                        }
                        if(menu == "Kredit") {
                          context.push('/manage/credits/credit');
                        }
                        if(menu == "Tabungan") {
                          if(subtype == 'saving') {
                            context.push('/manage/savings/saving');
                          }
                          if(subtype == 'record') {
                            context.push('/manage/savings/saving/record');
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        shape: CircleBorder(),
                        side: BorderSide(width: 1, color: (menu == 'Kredit' && subtype == 'bill') ? Colors.transparent : mainBlue),
                        backgroundColor: (menu == 'Kredit' && subtype == 'bill') ? Colors.transparent : mainBlue,
                        padding: EdgeInsets.zero,
                        minimumSize: Size(40, 40),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: (menu == 'Kredit' && subtype == 'bill') ? Colors.transparent : Colors.white,
                        size: 30
                      ),
                    ),
        
                  if(page == "Detail" && type == 'view')
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: OutlinedButton(
                        onPressed: () {
                          if(menu == "Akun") {
                            context.push('/manage/accounts/account/$id?action=edit&from=bar');
                          }
                          if(menu == "Kategori") {
                            if(subtype == 'category') {
                              context.push('/manage/categories/category/${id}?action=edit&from=bar');
                            }
                            if(subtype == 'subcategory') {
                              context.push('/manage/categories/category/${id}/subcategory/$subIndex?action=edit&from=bar');
                            }
                          }
                          if(menu == "Transaksi") {
                            context.push('/manage/transactions/$subtype/$id?action=edit&from=bar');
                          }
                          if(menu == "Kredit") {
                            context.push('/manage/credits/credit/$id?action=edit&from=bar');
                          }
                          if(menu == "Tabungan") {
                            if(subtype == 'saving') {
                              context.push('/manage/savings/saving/${id}?action=edit&from=bar');
                            }
                            if(subtype == 'record') {
                              context.push('/manage/savings/saving/record/${id}/$subIndex?action=edit&from=bar');
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          shape: CircleBorder(),
                          side: BorderSide(width: 1, color: mainBlue),
                          padding: EdgeInsets.zero,
                          minimumSize: Size(40, 40),
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          color: mainBlue,
                          size: 25
                        ),
                      ),
                    ),
                  if(page == "Detail" && type == 'view')
                    OutlinedButton(
                      onPressed: ((menu == 'Akun' && accountController.accountLength == 1) || (menu == 'Kategori' && categoryController.categories.where((category) => category.typeId == 0 && category.isDeleted == false).toList().length == 1 && categoryController.categories.where((category) => category.typeId == 1 && category.isDeleted == false).toList().length == 1)) ? null : () async {
                        bool confirm = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Hapus',
                                style: TextStyle(
                                  fontFamily: "Open Sans",
                                  fontWeight: FontWeight.w500,
                                  color: greyMinusTwo
                                )
                              ),
                              content: Text(
                                'Apakah Anda yakin ingin menghapus?',
                                style: TextStyle(
                                  fontSize: tiny
                                )
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: mainBlue),
                                          padding: EdgeInsets.symmetric(vertical: 10)
                                        ),
                                        child: Text(
                                          'Tidak',
                                          style: TextStyle(
                                            fontSize: tiny,
                                            fontWeight: FontWeight.w500
                                          )
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: mainBlue,
                                          side: BorderSide(color: mainBlue),
                                          padding: EdgeInsets.symmetric(vertical: 10)
                                        ),
                                        child: Text(
                                          'Ya',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: tiny,
                                            fontWeight: FontWeight.w500
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                      ),
                                    )
                                  ],
                                )
                              ],
                            );
                          }
                        );

                        if(confirm == true) {
                          Navigator.pop(context);
                          Map<String, dynamic> result = {};

                          if(menu == "Akun") {
                            result = await accountService.deleteAccount(user?.uid ?? '', id);

                            accountController.setAccount(
                              AccountModel(
                                id: '',
                                name: '',
                                amount: 0,
                                currency: '',
                                icon: '',
                                color: '',
                                isDeleted: false
                              )
                            );
                          }
                          
                          if(menu == "Kategori") {
                            if(subtype == 'category') {
                              result = await categoryService.deleteCategory(user?.uid ?? '', id);

                              categoryController.setSubcategory(-1);
                              categoryController.setCategory(
                                CategoryModel(
                                  id: '',
                                  name: '',
                                  typeId: -1,
                                  subs: null,
                                  icon: '',
                                  color: '',
                                  isDeleted: false
                                )
                              );
                            }
                            if(subtype == 'subcategory') {
                              result = await categoryService.deleteSubcategory(user?.uid ?? '', id, subIndex);

                              categoryController.setSubcategory(-1);
                              categoryController.setCategory(
                                CategoryModel(
                                  id: '',
                                  name: '',
                                  typeId: -1,
                                  subs: null,
                                  icon: '',
                                  color: '',
                                  isDeleted: false
                                )
                              );
                            }
                          }

                          if(menu == "Transaksi") {
                            if(subtype == 'transaction') {
                              result = await transactionService.deleteTransaction(user?.uid ?? '', id, 'transaction');

                              transactionController.setTransaction(
                                TransactionModel(
                                  id: '',
                                  amount: 0,
                                  category: null,
                                  accountId: Account(destination: '', source: ''),
                                  typeId: 0,
                                  fee: 0,
                                  note: '',
                                  date: Timestamp.fromDate(
                                    DateTime.now().toUtc().add(Duration(hours: 7)).subtract(
                                      Duration(
                                        hours: DateTime.now().toUtc().add(Duration(hours: 7)).hour,
                                        minutes: DateTime.now().toUtc().add(Duration(hours: 7)).minute,
                                        seconds: DateTime.now().toUtc().add(Duration(hours: 7)).second,
                                        milliseconds: DateTime.now().toUtc().add(Duration(hours: 7)).millisecond,
                                        microseconds: DateTime.now().toUtc().add(Duration(hours: 7)).microsecond,
                                      )
                                    ),
                                  )
                                )
                              );
                            }
                            if(subtype == 'plan') {
                              result = await transactionService.deleteTransaction(user?.uid ?? '', id, 'plan');

                              transactionController.setTransactionPlan(
                                TransactionPlanModel(
                                  id: '',
                                  isActive: true,
                                  amount: 0,
                                  category: null,
                                  accountId: Account(destination: '', source: ''),
                                  typeId: 0,
                                  fee: 0,
                                  note: '',
                                  name: '',
                                  frequency: Frequency(repeat: true, recurrence: null, startDate: Timestamp.fromDate(
                                    DateTime.now().toUtc().add(Duration(hours: 7)).subtract(
                                      Duration(
                                        hours: DateTime.now().toUtc().add(Duration(hours: 7)).hour,
                                        minutes: DateTime.now().toUtc().add(Duration(hours: 7)).minute,
                                        seconds: DateTime.now().toUtc().add(Duration(hours: 7)).second,
                                        milliseconds: DateTime.now().toUtc().add(Duration(hours: 7)).millisecond,
                                        microseconds: DateTime.now().toUtc().add(Duration(hours: 7)).microsecond,
                                      )
                                    ),
                                  ))
                                )
                              );
                            }
                          }

                          if(menu == "Kredit") {
                            result = await creditService.deleteCredit(user?.uid ?? '', id);

                            creditController.setCredit(
                              CreditModel(
                                id: '',
                                  provider: '',
                                  limitAmount: 0,
                                  currency: '',
                                  limits: null,
                                  dueDate: 0,
                                  cutOffDate: 0,
                                  icon: '',
                                  color: '',
                                  isDeleted: false
                              )
                            );
                          }

                          if(menu == "Tabungan") {
                            if(subtype == 'saving') {
                              result = await savingService.deleteSaving(user?.uid ?? '', id);

                              savingController.setSaving(
                                SavingModel(
                                  id: '',
                                  targetAmount: 0,
                                  currency: '',
                                  category: Category(id: '', subId: null),
                                  name: '',
                                  note: '',
                                  dueDate: Timestamp.fromDate(
                                    DateTime.now().toUtc().add(Duration(hours: 7)).subtract(
                                      Duration(
                                        hours: DateTime.now().toUtc().add(Duration(hours: 7)).hour,
                                        minutes: DateTime.now().toUtc().add(Duration(hours: 7)).minute,
                                        seconds: DateTime.now().toUtc().add(Duration(hours: 7)).second,
                                        milliseconds: DateTime.now().toUtc().add(Duration(hours: 7)).millisecond,
                                        microseconds: DateTime.now().toUtc().add(Duration(hours: 7)).microsecond,
                                      )
                                    ),
                                  ),
                                  records: null,
                                  isDeleted: false
                                )
                              );
                            }
                            if(subtype == 'record') {
                              result = await savingService.deleteRecord(user?.uid ?? '', id, subIndex);

                              savingController.setRecord(
                                Record(amount: 0, accountId: '', typeId: 0, date: Timestamp.fromDate(
                                  DateTime.now().toUtc().add(Duration(hours: 7)).subtract(
                                    Duration(
                                      hours: DateTime.now().toUtc().add(Duration(hours: 7)).hour,
                                      minutes: DateTime.now().toUtc().add(Duration(hours: 7)).minute,
                                      seconds: DateTime.now().toUtc().add(Duration(hours: 7)).second,
                                      milliseconds: DateTime.now().toUtc().add(Duration(hours: 7)).millisecond,
                                      microseconds: DateTime.now().toUtc().add(Duration(hours: 7)).microsecond,
                                    )
                                  ),
                                ))
                              );
                            }
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        shape: CircleBorder(),
                        side: BorderSide(width: 1, color: mainBlue),
                        padding: EdgeInsets.zero,
                        minimumSize: Size(40, 40),
                      ),
                      child: Icon(
                        Icons.delete_outlined,
                        color: mainBlue,
                        size: 27.5
                      ),
                    )
                ],
              )
            ],
          )
        ),
      )
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}