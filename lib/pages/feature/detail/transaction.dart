import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exinflow/controllers/account.dart';
import 'package:exinflow/controllers/category.dart';
import 'package:exinflow/controllers/credit.dart';
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
import 'package:intl/intl.dart';

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
  final AccountController accountController = Get.find<AccountController>();
  final CreditController creditController = Get.find<CreditController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final OneSubtabController oneSubtabController = Get.find<OneSubtabController>();
  final AllSubtabController allSubtabController = Get.find<AllSubtabController>();
  late TabController transactionTabController;
  late StreamSubscription<int> selectedTabSubscription;

  TransactionModel currentT = TransactionModel(
    id: '',
    amount: 0,
    category: Category(
      id: '',
      subId: null
    ),
    accountId: Account(
      destination: '',
      source: ''
    ),
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
  );

  TransactionPlanModel currentP = TransactionPlanModel(
    id: '',
    amount: 0,
    category: Category(
      id: '',
      subId: null
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
        timeUnitId: 0
      ),
      startDate: Timestamp.fromDate(
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

    Get.delete<TabController>(tag: 'transactionTabController');
    transactionTabController = Get.put(
      TabController(length: tabs.length, vsync: Scaffold.of(context)),
      tag: 'transactionTabController'
    );

    selectedTabSubscription = oneSubtabController.selectedTab.listen((index) {
      transactionTabController.animateTo(index);
    });

    if(widget.sub != 'plan') {
      currentT.amount = widget.action == 'add' ? 0 : transactionController.transaction?.amount ?? 0;
      currentT.category = Category(
        id: widget.action == 'add' ? categoryController.categories[0].id : transactionController.transaction?.category?.id ?? '',
        subId: widget.action == 'add' ? null : transactionController.transaction?.category?.subId
      );
      currentT.typeId = widget.action == 'add' ? 0 : transactionController.transaction?.typeId ?? 0;
      currentT.accountId.source = widget.action == 'add' ? currentT.typeId != 1 ? accountController.accounts[0].id : '' : transactionController.transaction?.accountId.source ?? '';
      currentT.accountId.destination = widget.action == 'add' ? currentT.typeId != 1 ? accountController.accounts[0].id : '' : transactionController.transaction?.accountId.destination ?? '';
      currentT.fee = widget.action == 'add' ? 0 : transactionController.transaction?.fee ?? 0;
      currentT.note = widget.action == 'add' ? '' : transactionController.transaction?.note ?? '';
      currentT.date = widget.action == 'add' ? Timestamp.fromDate(
        DateTime.now().toUtc().add(Duration(hours: 7)).subtract(
          Duration(
            hours: DateTime.now().toUtc().add(Duration(hours: 7)).hour,
            minutes: DateTime.now().toUtc().add(Duration(hours: 7)).minute,
            seconds: DateTime.now().toUtc().add(Duration(hours: 7)).second,
            milliseconds: DateTime.now().toUtc().add(Duration(hours: 7)).millisecond,
            microseconds: DateTime.now().toUtc().add(Duration(hours: 7)).microsecond,
          )
        ),
      ) : transactionController.transaction?.date ?? Timestamp.fromDate(
        DateTime.now().toUtc().add(Duration(hours: 7)).subtract(
          Duration(
            hours: DateTime.now().toUtc().add(Duration(hours: 7)).hour,
            minutes: DateTime.now().toUtc().add(Duration(hours: 7)).minute,
            seconds: DateTime.now().toUtc().add(Duration(hours: 7)).second,
            milliseconds: DateTime.now().toUtc().add(Duration(hours: 7)).millisecond,
            microseconds: DateTime.now().toUtc().add(Duration(hours: 7)).microsecond,
          )
        ),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        oneSubtabController.changeTab(0);
        if(widget.action != 'add') {
          oneSubtabController.changeTab(currentT.typeId);
        }
      });
    } else {
      currentP.name = widget.action == 'add' ? '' : transactionController.transactionPlan?.name ?? '';
      currentP.amount = widget.action == 'add' ? 0 : transactionController.transactionPlan?.amount ?? 0;
      currentP.category = Category(
        id: widget.action == 'add' ? categoryController.categories[0].id : transactionController.transactionPlan?.category?.id ?? '',
        subId: widget.action == 'add' ? null : transactionController.transactionPlan?.category?.subId
      );
      currentP.typeId = widget.action == 'add' ? 0 : transactionController.transactionPlan?.typeId ?? 0;
      currentP.accountId.source = widget.action == 'add' ? currentP.typeId != 1 ? accountController.accounts[0].id : '' : transactionController.transaction?.accountId.source ?? '';
      currentP.accountId.destination = widget.action == 'add' ? currentP.typeId != 1 ? accountController.accounts[0].id : '' : transactionController.transaction?.accountId.destination ?? '';
      currentP.fee = widget.action == 'add' ? 0 : transactionController.transactionPlan?.fee ?? 0;
      currentP.note = widget.action == 'add' ? '' : transactionController.transactionPlan?.note ?? '';
      currentP.isActive = widget.action == 'add' ? true : transactionController.transactionPlan?.isActive ?? true;
      currentP.frequency = Frequency(
        repeat: widget.action == 'add' ? true : transactionController.transactionPlan?.frequency.repeat ?? true,
        recurrence: Recurrence(
          count: widget.action == 'add' ? 0 : transactionController.transactionPlan?.frequency.recurrence?.count ?? 0,
          timeUnitId: widget.action == 'add' ? 0 : transactionController.transactionPlan?.frequency.recurrence?.timeUnitId ?? 0,
        ),
        startDate: widget.action == 'add' ? Timestamp.fromDate(
          DateTime.now().toUtc().add(Duration(hours: 7)).subtract(
            Duration(
              hours: DateTime.now().toUtc().add(Duration(hours: 7)).hour,
              minutes: DateTime.now().toUtc().add(Duration(hours: 7)).minute,
              seconds: DateTime.now().toUtc().add(Duration(hours: 7)).second,
              milliseconds: DateTime.now().toUtc().add(Duration(hours: 7)).millisecond,
              microseconds: DateTime.now().toUtc().add(Duration(hours: 7)).microsecond,
            )
          ),
        ) : transactionController.transactionPlan?.frequency.startDate ?? Timestamp.fromDate(
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
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        oneSubtabController.changeTab(0);
        if(widget.action != 'add') {
          oneSubtabController.changeTab(currentP.typeId);
        }
      });
    }
  }

  @override
  void dispose() {
    selectedTabSubscription.cancel();
    Get.delete<TabController>(tag: 'transactionTabController');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TabController transactionTabController = Get.put(
      TabController(length: tabs.length, vsync: Scaffold.of(context)),
      tag: 'transactionTabController'
    );
    oneSubtabController.selectedTab.listen((index) {
      if(index <= tabs.length - 1) {
        transactionTabController.animateTo(index);
      }
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
                  padding: EdgeInsets.only(bottom: widget.action == 'view' ? 0 : 75),
                  child: Obx(() {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Subtab(tabs: tabs, type: 'one', disabled: widget.action != 'add' ? true : false, controller: transactionTabController),

                        if(widget.sub == 'plan')
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
                                    setState(() {
                                      currentP.name = value;
                                    });
                                  },
                                  initialValue: currentP.name,
                                  style: TextStyle(
                                    fontSize: semiVerySmall
                                  ),
                                  decoration: InputDecoration(
                                    hintText: widget.action == 'view' ? transactionController.transactionPlan?.name ?? '' : 'Nama transaksi berulang',
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

                        Padding(
                          padding: const EdgeInsets.only(bottom: 17.5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  "Jumlah",
                                  style: TextStyle(
                                    fontSize: small,
                                    color: greyMinusTwo
                                  ),
                                ),
                              ),
                              TextFormField(
                                enabled: widget.action == 'add' || widget.action == 'edit' ? true : false,
                                onChanged: (value) {
                                  setState(() {
                                    if(widget.sub == 'plan') {
                                      currentP.amount = double.tryParse(value) ?? 0;
                                    } else {
                                      currentT.amount = double.tryParse(value) ?? 0;
                                    }
                                  });
                                },
                                initialValue: widget.sub == 'plan' ? currentP.amount.toString() : currentT.amount.toString(),
                                style: TextStyle(
                                  fontSize: semiVerySmall
                                ),
                                decoration: InputDecoration(
                                  hintText: widget.action == 'view' ? widget.sub == 'plan' ? transactionController.transactionPlan?.amount.toString() ?? '' : transactionController.transaction?.amount.toString() : 'Jumlah uang',
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

                        if(oneSubtabController.selectedTab.value != 2)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 17.5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    "Akun",
                                    style: TextStyle(
                                      fontSize: small,
                                      color: greyMinusTwo
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: greyMinusFour, width: 1),
                                      borderRadius: borderRadius,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: (currentT.accountId.source == '' && currentT.accountId.destination == '' && currentP.accountId.source == '' && currentP.accountId.destination == '') ?
                                            accountController.accounts.firstWhere((account) => !account.isDeleted).id :
                                            widget.sub != 'plan' ?
                                              (widget.action == 'add' ? oneSubtabController.selectedTab.value == 0 : currentT.typeId == 0) ?
                                                currentT.accountId.source :
                                                currentT.accountId.destination :
                                              (widget.action == 'add' ? oneSubtabController.selectedTab.value == 0 : currentP.typeId == 0) ?
                                                currentP.accountId.source :
                                                currentP.accountId.destination,
                                          items: [
                                            ...accountController.accounts.where((account) => account.isDeleted == true && account.id == (widget.sub != 'plan' ? currentT.typeId == 0 ? currentT.accountId.source : currentT.accountId.destination : currentP.typeId == 0 ? currentP.accountId.source : currentP.accountId.destination)).toList().map((account) {
                                              return DropdownMenuItem(
                                                value: account.id,
                                                child: Text(account.name),
                                              );
                                            }).toList(),
                                            ...accountController.accounts.where((account) => account.isDeleted == false).toList().map((account) {
                                              return DropdownMenuItem(
                                                value: account.id,
                                                child: Text(account.name),
                                              );
                                            }).toList(),
                                            if(oneSubtabController.selectedTab.value == 0)
                                              ...creditController.credits.where((credit) => credit.isDeleted == true && credit.id == (widget.sub != 'plan' ? currentT.typeId == 0 ? currentT.accountId.source : currentT.accountId.destination : currentP.typeId == 0 ? currentP.accountId.source : currentP.accountId.destination)).toList().map((credit) {
                                                return DropdownMenuItem(
                                                  value: credit.id,
                                                  child: Text(credit.provider),
                                                );
                                              }).toList(),
                                            if(oneSubtabController.selectedTab.value == 0)
                                              ...creditController.credits.where((credit) => credit.isDeleted == false).toList().map((credit) {
                                                return DropdownMenuItem(
                                                  value: credit.id,
                                                  child: Text(credit.provider),
                                                );
                                              }).toList()
                                          ],
                                          style: TextStyle(
                                            fontSize: semiVerySmall,
                                            color: greyMinusTwo
                                          ),
                                          onChanged: widget.action == 'add' || widget.action == 'edit' ? (value) {
                                            setState(() {
                                              if(widget.sub != 'plan') {
                                                if(oneSubtabController.selectedTab.value == 0) {
                                                  currentT.accountId.source = value ?? '';
                                                } else {
                                                  currentT.accountId.destination = value ?? '';
                                                }
                                              } else {
                                                if(oneSubtabController.selectedTab.value == 0) {
                                                  currentP.accountId.source = value ?? '';
                                                } else {
                                                  currentP.accountId.destination = value ?? '';
                                                }
                                              }
                                            });
                                          } : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        if(oneSubtabController.selectedTab.value == 2)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 17.5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(right: 7.5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            "Akun Asal",
                                            style: TextStyle(
                                              fontSize: small,
                                              color: greyMinusTwo
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              border: Border.all(color: greyMinusFour, width: 1),
                                              borderRadius: borderRadius,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  value: (currentT.accountId.source == '' && currentP.accountId.source == '') ?
                                                    accountController.accounts.firstWhere((account) => !account.isDeleted).id :
                                                    [
                                                      ...accountController.accounts.where((account) => account.isDeleted == true && account.id == (widget.sub != 'plan' ? currentT.accountId.source : currentP.accountId.source)).toList().map((account) {
                                                        return DropdownMenuItem(
                                                          value: account.id,
                                                          child: Text(account.name),
                                                        );
                                                      }).toList(),
                                                      ...accountController.accounts.where((account) => account.isDeleted == false).toList().map((account) {
                                                        return DropdownMenuItem(
                                                          value: account.id,
                                                          child: Text(account.name),
                                                        );
                                                      }).toList(),
                                                    ].any((account) => account.value == (widget.sub != 'plan' ? currentT.accountId.source : currentP.accountId.source)) ?
                                                      widget.sub != 'plan' ?
                                                        currentT.accountId.source :
                                                        currentP.accountId.source :
                                                      accountController.accounts.firstWhere((account) => !account.isDeleted).id,
                                                  items: [
                                                    ...accountController.accounts.where((account) => account.isDeleted == true && account.id == (widget.sub != 'plan' ? currentT.accountId.source : currentP.accountId.source)).toList().map((account) {
                                                      return DropdownMenuItem(
                                                        value: account.id,
                                                        child: Text(account.name),
                                                      );
                                                    }).toList(),
                                                    ...accountController.accounts.where((account) => account.isDeleted == false).toList().map((account) {
                                                      return DropdownMenuItem(
                                                        value: account.id,
                                                        child: Text(account.name),
                                                      );
                                                    }).toList(),
                                                  ],
                                                  style: TextStyle(
                                                    fontSize: semiVerySmall,
                                                    color: greyMinusTwo
                                                  ),
                                                  onChanged: widget.action == 'add' || widget.action == 'edit' ? (value) {
                                                    setState(() {
                                                      if(widget.sub != 'plan') {
                                                        currentT.accountId.source = value ?? '';
                                                      } else {
                                                        currentP.accountId.source = value ?? '';
                                                      }
                                                    });
                                                  } : null,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 7.5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            "Akun Tujuan",
                                            style: TextStyle(
                                              fontSize: small,
                                              color: greyMinusTwo
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              border: Border.all(color: greyMinusFour, width: 1),
                                              borderRadius: borderRadius,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  value: (currentT.accountId.destination == '' && currentP.accountId.destination == '') ?
                                                    accountController.accounts.firstWhere((account) => !account.isDeleted).id :
                                                    [
                                                      ...accountController.accounts.where((account) => account.isDeleted == true && account.id == (widget.sub != 'plan' ? currentT.accountId.destination : currentP.accountId.destination)).toList().map((account) {
                                                        return DropdownMenuItem(
                                                          value: account.id,
                                                          child: Text(account.name),
                                                        );
                                                      }).toList(),
                                                      ...accountController.accounts.where((account) => account.isDeleted == false).toList().map((account) {
                                                        return DropdownMenuItem(
                                                          value: account.id,
                                                          child: Text(account.name),
                                                        );
                                                      }).toList(),
                                                    ].any((account) => account.value == (widget.sub != 'plan' ? currentT.accountId.destination : currentP.accountId.destination)) ?
                                                      widget.sub != 'plan' ?
                                                        currentT.accountId.destination :
                                                        currentP.accountId.destination :
                                                      accountController.accounts.firstWhere((account) => !account.isDeleted).id,
                                                  items: [
                                                    ...accountController.accounts.where((account) => account.isDeleted == true && account.id == (widget.sub != 'plan' ? currentT.accountId.destination : currentP.accountId.destination)).toList().map((account) {
                                                      return DropdownMenuItem(
                                                        value: account.id,
                                                        child: Text(account.name),
                                                      );
                                                    }).toList(),
                                                    ...accountController.accounts.where((account) => account.isDeleted == false).toList().map((account) {
                                                      return DropdownMenuItem(
                                                        value: account.id,
                                                        child: Text(account.name),
                                                      );
                                                    }).toList(),
                                                  ],
                                                  style: TextStyle(
                                                    fontSize: semiVerySmall,
                                                    color: greyMinusTwo
                                                  ),
                                                  onChanged: widget.action == 'add' || widget.action == 'edit' ? (value) {
                                                    setState(() {
                                                      if(widget.sub != 'plan') {
                                                        currentT.accountId.destination = value ?? '';
                                                      } else {
                                                        currentP.accountId.destination = value ?? '';
                                                      }
                                                    });
                                                  } : null,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),

                        if(oneSubtabController.selectedTab.value != 2)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 17.5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    "Kategori",
                                    style: TextStyle(
                                      fontSize: small,
                                      color: greyMinusTwo
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: greyMinusFour, width: 1),
                                      borderRadius: borderRadius,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: (currentT.typeId == 2 || currentP.typeId == 2) ? '' : (currentT.category?.id == '' && currentP.category?.id == '') ?
                                            categoryController.categories.firstWhere((category) => !category.isDeleted && category.typeId == (widget.action == 'add' ? oneSubtabController.selectedTab.value : widget.sub != 'plan' ? currentT.typeId : currentP.typeId)).id :
                                            widget.sub != 'plan' ?
                                              currentT.category == null ?
                                                null :
                                                currentT.category?.id == '' ?
                                                  null :
                                                  currentT.category!.subId == null ?
                                                    categoryController.categories.where((category) => category.isDeleted == false && category.typeId == (widget.action == 'add' ? oneSubtabController.selectedTab.value : currentT.typeId)).toList().expand((category) {
                                                      List<DropdownMenuItem<String>> items = [
                                                        DropdownMenuItem(
                                                          value: category.id,
                                                          child: Text(category.name),
                                                        ),
                                                      ];
                                                      
                                                      return items;
                                                    }).toList().any((category) => category.value == currentT.category?.id) ?
                                                      currentT.category?.id :
                                                      categoryController.categories.firstWhere((category) => !category.isDeleted && category.typeId == (widget.action == 'add' ? oneSubtabController.selectedTab.value : currentT.typeId)).id :
                                                    categoryController.categories.where((category) => category.isDeleted == false && category.typeId == (widget.action == 'add' ? oneSubtabController.selectedTab.value : currentT.typeId)).toList().expand((category) {
                                                      List<DropdownMenuItem<String>> items = [];

                                                      if(category.subs != null) {
                                                        items.addAll(category.subs!.asMap().entries.where((sub) => sub.value.isDeleted == false).map((sub) {
                                                          return DropdownMenuItem(
                                                            value: "${category.id}|${sub.key}",
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(left: 25),
                                                              child: Text(sub.value.name),
                                                            ),
                                                          );
                                                        }));
                                                      }
                                                      
                                                      return items;
                                                    }).toList().any((category) => category.value == '${currentT.category?.id}|${currentT.category?.subId}') ?
                                                      '${currentT.category?.id}|${currentT.category?.subId}' :
                                                      categoryController.categories.firstWhere((category) => !category.isDeleted && category.typeId == (widget.action == 'add' ? oneSubtabController.selectedTab.value : currentT.typeId)).id :
                                              currentP.category == null ?
                                                null :
                                                currentP.category?.id == '' ?
                                                  null :
                                                  currentP.category!.subId == null ?
                                                    categoryController.categories.where((category) => category.isDeleted == false && category.typeId == (widget.action == 'add' ? oneSubtabController.selectedTab.value : currentP.typeId)).toList().expand((category) {
                                                      List<DropdownMenuItem<String>> items = [
                                                        DropdownMenuItem(
                                                          value: category.id,
                                                          child: Text(category.name),
                                                        ),
                                                      ];
                                                      
                                                      return items;
                                                    }).toList().any((category) => category.value == currentP.category?.id) ?
                                                      currentP.category?.id :
                                                      categoryController.categories.firstWhere((category) => !category.isDeleted && category.typeId == (widget.action == 'add' ? oneSubtabController.selectedTab.value : currentP.typeId)).id :
                                                    categoryController.categories.where((category) => category.isDeleted == false && category.typeId == (widget.action == 'add' ? oneSubtabController.selectedTab.value : currentP.typeId)).toList().expand((category) {
                                                      List<DropdownMenuItem<String>> items = [];

                                                      if(category.subs != null) {
                                                        items.addAll(category.subs!.asMap().entries.where((sub) => sub.value.isDeleted == false).map((sub) {
                                                          return DropdownMenuItem(
                                                            value: "${category.id}|${sub.key}",
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(left: 25),
                                                              child: Text(sub.value.name),
                                                            ),
                                                          );
                                                        }));
                                                      }
                                                      
                                                      return items;
                                                    }).toList().any((category) => category.value == '${currentP.category?.id}|${currentP.category?.subId}') ?
                                                      '${currentP.category?.id}|${currentP.category?.subId}' :
                                                      categoryController.categories.firstWhere((category) => !category.isDeleted && category.typeId == (widget.action == 'add' ? oneSubtabController.selectedTab.value : currentP.typeId)).id,
                                          items: categoryController.categories.where((category) => category.isDeleted == false && category.typeId == (widget.action == 'add' ? oneSubtabController.selectedTab.value : widget.sub != 'plan' ? currentT.typeId : currentP.typeId)).toList().expand((category) {
                                            List<DropdownMenuItem<String>> items = [
                                              DropdownMenuItem(
                                                value: category.id,
                                                child: Text(category.name),
                                              ),
                                            ];

                                            if(category.subs != null) {
                                              items.addAll(category.subs!.asMap().entries.where((sub) => sub.value.isDeleted == false).map((sub) {
                                                return DropdownMenuItem(
                                                  value: "${category.id}|${sub.key}",
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 25),
                                                    child: Text(sub.value.name),
                                                  ),
                                                );
                                              }));
                                            }
                                            
                                            return items;
                                          }).toList(),
                                          style: TextStyle(
                                            fontSize: semiVerySmall,
                                            color: greyMinusTwo
                                          ),
                                          onChanged: widget.action == 'add' || widget.action == 'edit' ? (value) {
                                            if ((value ?? '').contains('|')) {
                                              List<String> parts = (value ?? '').split('|');
                                              print('First item: ${parts[0]}');
                                              print('Second item: ${parts[1]}');
                                            } else {
                                              print('String $value cannot be split by "|".');
                                            }
                                            setState(() {
                                              if(widget.sub != 'plan') {
                                                currentT.category = Category(
                                                  id: (value ?? '').contains('|') ? (value ?? '').split('|')[0] : value ?? '',
                                                  subId: (value ?? '').contains('|') ? int.parse((value ?? '').split('|')[1]) : null
                                                );
                                              } else {
                                                currentP.category = Category(
                                                  id: (value ?? '').contains('|') ? (value ?? '').split('|')[0] : value ?? '',
                                                  subId: (value ?? '').contains('|') ? int.parse((value ?? '').split('|')[1]) : null
                                                );
                                              }
                                            });
                                          } : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if(oneSubtabController.selectedTab.value == 2)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 17.5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    "Biaya",
                                    style: TextStyle(
                                      fontSize: small,
                                      color: greyMinusTwo
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  enabled: widget.action == 'add' || widget.action == 'edit' ? true : false,
                                  onChanged: (value) {
                                    setState(() {
                                      if(widget.sub == 'plan') {
                                        currentP.fee = double.tryParse(value) ?? 0;
                                      } else {
                                        currentT.fee = double.tryParse(value) ?? 0;
                                      }
                                    });
                                  },
                                  initialValue: widget.sub == 'plan' ? currentP.fee.toString() : currentT.fee.toString(),
                                  style: TextStyle(
                                    fontSize: semiVerySmall
                                  ),
                                  decoration: InputDecoration(
                                    hintText: widget.action == 'view' ? widget.sub == 'plan' ? transactionController.transactionPlan?.fee.toString() ?? '' : transactionController.transaction?.fee.toString() : 'Biaya transaksi',
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

                        if(widget.sub == 'transaction')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 17.5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    "Tanggal",
                                    style: TextStyle(
                                      fontSize: small,
                                      color: greyMinusTwo
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  readOnly: true,
                                  onTap: widget.action == 'add' || widget.action == 'edit' ? () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: currentT.date.toDate().toUtc().add(Duration(hours: 7)),
                                      firstDate: DateTime(2010, 1, 1),
                                      lastDate: DateTime(2100, 1, 1),
                                    );

                                    if (pickedDate != null) {
                                      Timestamp timestamp = Timestamp.fromDate(pickedDate);
                                      setState(() {
                                        currentT.date = timestamp;
                                      });
                                    }
                                  } : null,
                                  style: TextStyle(
                                    fontSize: semiVerySmall
                                  ),
                                  decoration: InputDecoration(
                                    hintText: DateFormat('dd MMMM yyyy', 'id_ID').format(currentT.date.toDate().toUtc().add(Duration(hours: 7))),
                                    hintStyle: widget.action == 'view' ? TextStyle(
                                      color: greyMinusThree
                                    ) : null,
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
                                )
                              ],
                            ),
                          ),

                        if(widget.sub == 'plan')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 17.5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    "Jenis Perulangan",
                                    style: TextStyle(
                                      fontSize: small,
                                      color: greyMinusTwo
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: greyMinusFour, width: 1),
                                      borderRadius: borderRadius,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: currentP.frequency.repeat == true ? 'true' : 'false',
                                          items: [
                                            DropdownMenuItem(
                                              value: 'true',
                                              child: Text('Berulang'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'false',
                                              child: Text('Tidak Berulang'),
                                            ),
                                          ],
                                          style: TextStyle(
                                            fontSize: semiVerySmall,
                                            color: greyMinusTwo
                                          ),
                                          onChanged: widget.action == 'add' || widget.action == 'edit' ? (value) {
                                            setState(() {
                                              currentP.frequency.repeat = value == 'true' ? true : false;
                                            });
                                          } : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if(widget.sub == 'plan' && currentP.frequency.repeat == true)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 17.5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(right: 7.5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            "Setiap",
                                            style: TextStyle(
                                              fontSize: small,
                                              color: greyMinusTwo
                                            ),
                                          ),
                                        ),
                                        TextFormField(
                                          enabled: widget.action == 'add' || widget.action == 'edit' ? true : false,
                                          onChanged: (value) {
                                            setState(() {
                                              currentP.frequency.recurrence?.count = int.parse((value == '' || value == null) ? '0' : value);
                                            });
                                          },
                                          initialValue: currentP.frequency.recurrence?.count.toString(),
                                          style: TextStyle(
                                            fontSize: semiVerySmall
                                          ),
                                          decoration: InputDecoration(
                                            hintText: widget.action == 'view' ? transactionController.transactionPlan?.frequency.recurrence?.count.toString() ?? '' : 'Setiap',
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 7.5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            "Waktu",
                                            style: TextStyle(
                                              fontSize: small,
                                              color: greyMinusTwo
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              border: Border.all(color: greyMinusFour, width: 1),
                                              borderRadius: borderRadius,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  value: currentP.frequency.recurrence?.timeUnitId.toString(),
                                                  items: [
                                                    DropdownMenuItem(
                                                      value: '0',
                                                      child: Text('Hari'),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: '1',
                                                      child: Text('Minggu'),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: '2',
                                                      child: Text('Bulan'),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: '3',
                                                      child: Text('Tahun'),
                                                    ),
                                                  ],
                                                  style: TextStyle(
                                                    fontSize: semiVerySmall,
                                                    color: greyMinusTwo
                                                  ),
                                                  onChanged: widget.action == 'add' || widget.action == 'edit' ? (value) {
                                                    setState(() {
                                                      currentP.frequency.recurrence?.timeUnitId = int.parse(value ?? '0');
                                                    });
                                                  } : null,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),

                        if(widget.sub == 'plan' && currentP.frequency.repeat == false)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 17.5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    "Jadwal Tanggal",
                                    style: TextStyle(
                                      fontSize: small,
                                      color: greyMinusTwo
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  readOnly: true,
                                  onTap: widget.action == 'add' || widget.action == 'edit' ? () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: currentP.frequency.startDate.toDate().toUtc().add(Duration(hours: 7)),
                                      firstDate: currentP.frequency.startDate.toDate().toUtc().add(Duration(hours: 7)),
                                      lastDate: DateTime(2100, 1, 1),
                                    );

                                    if (pickedDate != null) {
                                      Timestamp timestamp = Timestamp.fromDate(pickedDate);
                                      setState(() {
                                        currentP.frequency.startDate = timestamp;
                                      });
                                    }
                                  } : null,
                                  style: TextStyle(
                                    fontSize: semiVerySmall
                                  ),
                                  decoration: InputDecoration(
                                    hintText: DateFormat('dd MMMM yyyy', 'id_ID').format(currentP.frequency.startDate.toDate().toUtc().add(Duration(hours: 7))),
                                    hintStyle: widget.action == 'view' ? TextStyle(
                                      color: greyMinusThree
                                    ) : null,
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
                                )
                              ],
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 17.5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  "Catatan",
                                  style: TextStyle(
                                    fontSize: small,
                                    color: greyMinusTwo
                                  ),
                                ),
                              ),
                              TextFormField(
                                enabled: widget.action == 'add' || widget.action == 'edit' ? true : false,
                                onChanged: (value) {
                                  setState(() {
                                    if(widget.sub == 'plan') {
                                      currentP.note = value;
                                    } else {
                                      currentT.note = value;
                                    }
                                  });
                                },
                                initialValue: widget.sub == 'plan' ? currentP.note : currentT.note,
                                style: TextStyle(
                                  fontSize: semiVerySmall
                                ),
                                decoration: InputDecoration(
                                  hintText: widget.action == 'view' ? widget.sub == 'plan' ? transactionController.transactionPlan?.note ?? '' : transactionController.transaction?.note : 'Catatan',
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
                    );
                  }),
                )
              )
            ),

            if(widget.action == 'add' || widget.action == 'edit')
              AllPadding(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: mainBlueMinusTwo,
                      side: BorderSide(color: Colors.transparent),
                      padding: EdgeInsets.all(15)
                    ),
                    child: SizedBox(
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
                    ),
                    onPressed: () async {
                      TransactionModel dataT = currentT;
                      TransactionPlanModel dataP = currentP;
                      Map<String, dynamic> result = {};

                      if(widget.sub == 'plan' && currentP.name == '') {
                        result = {
                          'success': false,
                          'message': 'Nama transaksi harus diisi'
                        };
                        print(result);
                      } else if((widget.sub == 'plan' && currentP.amount == 0) || (widget.sub == 'transaction' && currentT.amount == 0)) {
                        result = {
                          'success': false,
                          'message': 'Jumlah uang harus diisi'
                        };
                        print(result);
                      } else if((widget.sub == 'plan' && oneSubtabController.selectedTab.value == 2 && currentP.accountId.source == currentP.accountId.destination) || (widget.sub == 'transaction' && oneSubtabController.selectedTab.value == 2 && currentT.accountId.source == currentT.accountId.destination)) {
                        result = {
                          'success': false,
                          'message': 'Akun asal dan tujuan tidak boleh sama'
                        };
                        print(result);
                      } else {
                        if(widget.action == 'add') {
                          if(widget.sub == 'plan') {
                            dataP.typeId = oneSubtabController.selectedTab.value;
                            if(dataP.typeId == 0) dataP.accountId.destination = null;
                            if(dataP.typeId == 1) dataP.accountId.source = null;
                            if(dataP.typeId == 2) dataP.category = null;
                            if(dataP.fee == 0) dataP.fee = null;
                            if(dataP.note == '') dataP.note = null;
                          } else {
                            dataT.typeId = oneSubtabController.selectedTab.value;
                            if(dataT.typeId == 0) dataT.accountId.destination = null;
                            if(dataT.typeId == 1) dataT.accountId.source = null;
                            if(dataT.typeId == 2) dataT.category = null;
                            if(dataT.fee == 0) dataT.fee = null;
                            if(dataT.note == '') dataT.note = null;
                          }
                          
                          result = await transactionService.createTransaction(user?.uid ?? '', widget.sub, widget.sub == 'plan' ? dataP : dataT);
                        } else if(widget.action == 'edit') {
                          if(widget.sub == 'plan') {
                            dataP.typeId = oneSubtabController.selectedTab.value;
                            if(dataP.typeId == 0) dataP.accountId.destination = null;
                            if(dataP.typeId == 1) dataP.accountId.source = null;
                            if(dataP.typeId == 2) dataP.category = null;
                            if(dataP.fee == 0) dataP.fee = null;
                            if(dataP.note == '') dataP.note = null;
                          } else {
                            dataT.typeId = oneSubtabController.selectedTab.value;
                            if(dataT.typeId == 0) dataT.accountId.destination = null;
                            if(dataT.typeId == 1) dataT.accountId.source = null;
                            if(dataT.typeId == 2) dataT.category = null;
                            if(dataT.fee == 0) dataT.fee = null;
                            if(dataT.note == '') dataT.note = null;
                          }

                          result = await transactionService.updateTransaction(user?.uid ?? '', widget.id, widget.sub, widget.sub == 'plan' ? dataP : dataT);
                        }
                      }

                      if(result['success'] == true) {
                        context.pop();
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