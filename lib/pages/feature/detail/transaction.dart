import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exinflow/controllers/subtab.dart';
import 'package:exinflow/controllers/user.dart';
import 'package:exinflow/models/common.dart';
import 'package:exinflow/models/transaction.dart';
import 'package:exinflow/services/transaction.dart';
import 'package:exinflow/widgets/alert.dart';
import 'package:exinflow/widgets/padding.dart';
import 'package:exinflow/widgets/subtab.dart';
import 'package:flutter/material.dart';
import 'package:exinflow/widgets/top_bar.dart';
import 'package:exinflow/constants/constants.dart';
import 'package:exinflow/constants/data.dart';
import 'package:exinflow/controllers/transaction.dart';
import 'package:exinflow/controllers/user.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; 

class TransactionDetail extends StatefulWidget {
  final String id;
  final String action;
  final String sub;

  TransactionDetail({Key? key, required this.id, required this.action, required this.sub}): super(key: key);

  @override
  State<TransactionDetail> createState() => _TransactionDetailState();
}

class _TransactionDetailState extends State<TransactionDetail> {
  final user = FirebaseAuth.instance.currentUser;
  final TransactionService transactionService = TransactionService();

  final UserController userController = Get.find<UserController>();
  final TransactionController transactionController = Get.find<TransactionController>();
  final SubtabController subtabController = Get.find<SubtabController>();
  late TabController transactionTabController;
  late StreamSubscription<int> selectedTabSubscription;

  TransactionModel currentT = TransactionModel(
    id: '',
    amount: 0,
    category: Category(
      id: '',
      subId: -1
    ),
    accountId: Account(
      destination: '',
      source: ''
    ),
    typeId: 0,
    fee: 0,
    note: '',
    date: Timestamp.fromDate(
      DateTime.now().subtract(
        Duration(
          hours: DateTime.now().hour,
          minutes: DateTime.now().minute,
          seconds: DateTime.now().second,
          milliseconds: DateTime.now().millisecond,
          microseconds: DateTime.now().microsecond,
        )
      ),
    )
  );

  TransactionPlanModel currentP = TransactionPlanModel(
    id: '',
    amount: 0,
    category: Category(
      id: '',
      subId: -1
    ),
    accountId: Account(
      destination: '',
      source: ''
    ),
    typeId: 0,
    fee: 0,
    note: '',
    isActive: true,
    name: '',
    frequency: Frequency(
      repeat: true,
      recurrence: Recurrence(
        count: 0,
        timeUnitId: 0,
        day: 0,
        week: 0,
        month: 0,
        year: 0
      ),
      startDate: Timestamp.fromDate(
        DateTime.now().subtract(
          Duration(
            hours: DateTime.now().hour,
            minutes: DateTime.now().minute,
            seconds: DateTime.now().second,
            milliseconds: DateTime.now().millisecond,
            microseconds: DateTime.now().microsecond,
          )
        ),
      ),
      endDate: Timestamp.fromDate(
        DateTime.now().subtract(
          Duration(
            hours: DateTime.now().hour,
            minutes: DateTime.now().minute,
            seconds: DateTime.now().second,
            milliseconds: DateTime.now().millisecond,
            microseconds: DateTime.now().microsecond,
          )
        ),
      )
    )
  );

  final List<Map> tabs = [
    {
      "tab": "Uang Keluar",
      "title": "Uang Keluar"
    },
    {
      "tab": "Uang Masuk",
      "title": "Uang Masuk"
    },
    {
      "tab": "Transfer",
      "title": "Transfer"
    },
  ];

  @override
  void initState() {
    super.initState();

    Get.delete<TabController>();
    transactionTabController = Get.put(TabController(length: tabs.length, vsync: Scaffold.of(context)));

    selectedTabSubscription = subtabController.selectedTab.listen((index) {
      transactionTabController.animateTo(index);
    });
  }

  @override
  void dispose() {
    subtabController.changeTab(0);
    selectedTabSubscription.cancel();
    Get.delete<TabController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TabController categoryTabController = Get.put(TabController(length: tabs.length, vsync: Scaffold.of(context)));
    subtabController.selectedTab.listen((index) {
      categoryTabController.animateTo(index);
    });

    return Scaffold(
      appBar: TopBar(
        id: widget.id,
        title: "Detail",
        menu: "Kategori",
        page: "Detail",
        type: widget.action,
        from: 'bar',
        subtype: widget.sub,
        subIndex: -1
      ),

      body: Center(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: AllPadding(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 75),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Subtab(tabs: tabs, controller: transactionTabController),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 17.5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                "Nama",
                                style: TextStyle(
                                  fontSize: small,
                                  color: greyMinusTwo
                                ),
                              ),
                            ),
                            TextFormField(
                              enabled: widget.action == 'add' || widget.action == 'edit' ? true : false,
                              onChanged: (value) {
                                // setState(() {
                                //   name = value;
                                // });
                              },
                              // initialValue: name,
                              style: TextStyle(
                                fontSize: semiVerySmall
                              ),
                              decoration: InputDecoration(
                                // hintText: widget.action == 'view' ? transactionController.transactionPlan?.name ?? '' : 'Nama ${widget.sub == 'category' ? 'kategori' : 'subkategori'}',
                                hintStyle: TextStyle(
                                  color: greyMinusThree
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: mainBlueMinusThree),
                                  borderRadius: borderRadius
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: greyMinusFour),
                                  borderRadius: borderRadius
                                ),
                              ),
                              keyboardType: TextInputType.name,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              )
            ),

            AllPadding(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: widget.action == 'add' || widget.action == 'edit' ? mainBlueMinusTwo : Colors.transparent,
                    side: BorderSide(color: widget.action == 'add' || widget.action == 'edit' ? Colors.transparent : mainBlueMinusTwo),
                    padding: EdgeInsets.all(widget.action == 'add' || widget.action == 'edit' ? 15 : 5)
                  ),
                  child: widget.action == 'add' || widget.action == 'edit' ? SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Simpan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: small,
                            fontWeight: FontWeight.w500
                          )
                        )
                      ],
                    ),
                  ) : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Lihat Transaksi',
                          style: TextStyle(
                            color: mainBlueMinusTwo,
                            fontSize: small,
                          )
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: borderRadius,
                          color: mainBlueMinusTwo
                        ),
                        child: Icon(
                          Icons.arrow_outward_rounded,
                          color: Colors.white,
                          size: 35,
                        ),
                      )
                    ],
                  ),
                  onPressed: () async {
                    if(widget.action == 'add' || widget.action == 'edit') {
                      // Map<String, dynamic> result = {};
                      // if(name == '') {
                      //   result = {
                      //     'success': false,
                      //     'message': 'Nama akun harus diisi'
                      //   };
                      // } else {
                      //   if(widget.action == 'add') {
                      //     if(widget.sub == 'category') {
                      //       result = await categoryService.createCategory(
                      //         user?.uid ?? '',
                      //         false,
                      //         {
                      //           'Name': name,
                      //           'Type_Id': subtabController.selectedTab.value,
                      //           'Icon': iconController.selectedIcon.value == '' ? 'account_balance_wallet_outlined' : iconController.selectedIcon.value,
                      //           'Color': colorController.selectedColor.value == '' ? '0f667b' : colorController.selectedColor.value,
                      //         }
                      //       );
                      //     }
                      //     if(widget.sub == 'subcategory') {
                      //       result = await categoryService.createSubcategory(
                      //         user?.uid ?? '',
                      //         false,
                      //         widget.id,
                      //         {
                      //           'Name': name,
                      //           'Icon': iconController.selectedIcon.value == '' ? 'account_balance_wallet_outlined' : iconController.selectedIcon.value,
                      //         }
                      //       );
                      //     }
                      //   } else if(widget.action == 'edit') {
                      //     if(widget.sub == 'category') {
                      //       result = await categoryService.updateCategory(
                      //         user?.uid ?? '',
                      //         widget.id,
                      //         {
                      //           'Name': name,
                      //           'Icon': iconController.selectedIcon.value == '' ? icon : iconController.selectedIcon.value,
                      //           'Color': colorController.selectedColor.value == '' ? color : colorController.selectedColor.value,
                      //         }
                      //       );
                      //     }
                      //     if(widget.sub == 'subcategory') {
                      //       result = await categoryService.updateSubcategory(
                      //         user?.uid ?? '',
                      //         widget.id,
                      //         widget.subIndex,
                      //         {
                      //           'Name': name,
                      //           'Icon': iconController.selectedIcon.value == '' ? icon : iconController.selectedIcon.value,
                      //         }
                      //       );
                      //     }
                      //   }

                      //   if(result['success'] == true) {
                      //     context.pop();
                      //     subtabController.changeTab(subtabController.selectedTab.value);
                      //   }
                      // }
                    } else {

                    }
                  },
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}