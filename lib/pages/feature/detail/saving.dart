import 'package:exinflow/controllers/user.dart';
import 'package:exinflow/models/common.dart';
import 'package:exinflow/models/saving.dart';
import 'package:exinflow/services/saving.dart';
import 'package:exinflow/widgets/alert.dart';
import 'package:exinflow/widgets/padding.dart';
import 'package:exinflow/widgets/subtab.dart';
import 'package:flutter/material.dart';
import 'package:exinflow/widgets/top_bar.dart';
import 'package:exinflow/constants/constants.dart';
import 'package:exinflow/constants/data.dart';
import 'package:exinflow/controllers/user.dart';
import 'package:exinflow/controllers/saving.dart';
import 'package:exinflow/controllers/category.dart';
import 'package:exinflow/controllers/account.dart';
import 'package:exinflow/controllers/subtab.dart';
import 'package:exinflow/models/account.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class SavingDetail extends StatefulWidget {
  final String id;
  final String action;
  final String from;
  final int subIndex;
  final String sub;

  SavingDetail({
    Key? key,
    required this.id,
    required this.action,
    required this.from,
    required this.subIndex,
    required this.sub,
  }): super(key: key);

  @override
  State<SavingDetail> createState() => _SavingDetailState();
}

class _SavingDetailState extends State<SavingDetail> {
  final user = FirebaseAuth.instance.currentUser;
  final SavingService savingService = SavingService();

  final UserController userController = Get.find<UserController>();
  final SavingController savingController = Get.find<SavingController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final AccountController accountController = Get.find<AccountController>();
  final OneSubtabController oneSubtabController = Get.find<OneSubtabController>();
  late TabController savingTabController;
  late StreamSubscription<int> selectedTabSubscription;

  String savingId = '';

  SavingModel currentS = SavingModel(
    id: '',
    targetAmount: 0,
    currency: '',
    category: Category(
      id: '',
      subId: null
    ),
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
  );

  Record currentR = Record(
    amount: 0,
    accountId: '',
    typeId: 0,
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

  final List<Map> tabs = [
    {
      "tab": "Uang Keluar",
      "title": "Uang Keluar"
    },
    {
      "tab": "Uang Masuk",
      "title": "Uang Masuk"
    },
  ];

  @override
  void initState() {
    super.initState();

    setState(() {
      if(widget.id != '') {
        savingId = widget.id;
      } else {
        savingId = savingController.savings.firstWhere((saving) => !saving.isDeleted).id;
      }
    });

    Get.delete<TabController>(tag: 'savingTabController');
    savingTabController = Get.put(
      TabController(length: tabs.length, vsync: Scaffold.of(context)),
      tag: 'savingTabController'
    );

    selectedTabSubscription = oneSubtabController.selectedTab.listen((index) {
      savingTabController.animateTo(index);
    });

    if(widget.sub == 'saving') {
      currentS.targetAmount = widget.action == 'add' ? 0 : savingController.saving?.targetAmount ?? 0;
      currentS.currency = widget.action == 'add' ? userController.user?.mainCurrency ?? '' : savingController.saving?.currency ?? '';
      currentS.category = Category(
        id: widget.action == 'add' ? categoryController.categories[0].id : savingController.saving?.category?.id ?? '',
        subId: widget.action == 'add' ? null : savingController.saving?.category?.subId
      );
      currentS.currency = widget.action == 'add' ? userController.user?.mainCurrency ?? '' : savingController.saving?.currency ?? '';
      currentS.name = widget.action == 'add' ? '' : savingController.saving?.name ?? '';
      currentS.note = widget.action == 'add' ? '' : savingController.saving?.note ?? '';
      currentS.dueDate = widget.action == 'add' ? Timestamp.fromDate(
        DateTime.now().toUtc().add(Duration(hours: 7)).subtract(
          Duration(
            hours: DateTime.now().toUtc().add(Duration(hours: 7)).hour,
            minutes: DateTime.now().toUtc().add(Duration(hours: 7)).minute,
            seconds: DateTime.now().toUtc().add(Duration(hours: 7)).second,
            milliseconds: DateTime.now().toUtc().add(Duration(hours: 7)).millisecond,
            microseconds: DateTime.now().toUtc().add(Duration(hours: 7)).microsecond,
          )
        ),
      ) : savingController.saving?.dueDate ?? Timestamp.fromDate(
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
    } else {
      currentR.amount = widget.action == 'add' ? 0 : savingController.record?.amount ?? 0;
      currentR.accountId = widget.action == 'add' ? accountController.accounts[0].id : savingController.record?.accountId ?? accountController.accounts[0].id;
      currentR.typeId = widget.action == 'add' ? 0 : savingController.record?.typeId ?? 0;
      currentR.date = widget.action == 'add' ? Timestamp.fromDate(
        DateTime.now().toUtc().add(Duration(hours: 7)).subtract(
          Duration(
            hours: DateTime.now().toUtc().add(Duration(hours: 7)).hour,
            minutes: DateTime.now().toUtc().add(Duration(hours: 7)).minute,
            seconds: DateTime.now().toUtc().add(Duration(hours: 7)).second,
            milliseconds: DateTime.now().toUtc().add(Duration(hours: 7)).millisecond,
            microseconds: DateTime.now().toUtc().add(Duration(hours: 7)).microsecond,
          )
        ),
      ) : savingController.record?.date ?? Timestamp.fromDate(
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
          oneSubtabController.changeTab(currentR.typeId);
        }
      });
    }
  }

  @override
  void dispose() {
    selectedTabSubscription.cancel();
    Get.delete<TabController>(tag: 'savingTabController');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TabController savingTabController = Get.put(
      TabController(length: tabs.length, vsync: Scaffold.of(context)),
      tag: 'savingTabController'
    );
    oneSubtabController.selectedTab.listen((index) {
      if(index <= tabs.length - 1) {
        savingTabController.animateTo(index);
      }
    });

    return Scaffold(
      appBar: TopBar(
        id: widget.id,
        title: "Detail",
        menu: "Tabungan",
        page: "Detail",
        type: widget.action,
        from: widget.from,
        subtype: widget.sub,
        subIndex: widget.sub == 'subcategory' ? widget.subIndex : -1,
      ),

      body: Center(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: AllPadding(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 75),
                  child: Obx(() {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(widget.sub == 'record')
                          Subtab(tabs: tabs, type: 'one', disabled: widget.action != 'add' ? true : false, controller: savingTabController),

                        if(widget.sub == 'saving')
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
                                      currentS.name = value;
                                    });
                                  },
                                  initialValue: currentS.name,
                                  style: TextStyle(
                                    fontSize: semiVerySmall
                                  ),
                                  decoration: InputDecoration(
                                    hintText: widget.action == 'view' ? savingController.saving?.name ?? '' : 'Nama tabungan',
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
                                  "Jumlah ${widget.sub == 'saving' ? 'Target' : 'Uang'}",
                                  style: TextStyle(
                                    fontSize: small,
                                    color: greyMinusTwo
                                  ),
                                ),
                              ),
                              TextFormField(
                                enabled: widget.action == 'add' ? true : false,
                                onChanged: (value) {
                                  setState(() {
                                    if(widget.sub == 'saving') currentS.targetAmount = double.tryParse(value) ?? 0;
                                    if(widget.sub == 'record') currentR.amount = double.tryParse(value) ?? 0;
                                  });
                                },
                                initialValue: widget.sub == 'saving' ? currentS.targetAmount.toString() : currentR.amount.toString(),
                                style: TextStyle(
                                  fontSize: semiVerySmall
                                ),
                                decoration: InputDecoration(
                                  hintText: widget.action == 'view' ? widget.sub == 'saving' ? savingController.saving?.targetAmount.toString() ?? '' : savingController.record?.amount.toString() ?? '' : 'Jumlah ${widget.sub == 'saving' ? 'target' : 'uang ditabung'}',
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
                                keyboardType: TextInputType.number,
                              )
                            ],
                          ),
                        ),
                    
                        if(widget.sub == 'saving')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 17.5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    "Mata Uang",
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
                                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: currentS.currency,
                                          items: currencies.map((currency) {
                                            return DropdownMenuItem(
                                              value: currency['ISO_Code'],
                                              child: Text(currency['Name_ID'] ?? ''),
                                            );
                                          }).toList(),
                                          style: TextStyle(
                                            fontSize: semiVerySmall,
                                            color: greyMinusTwo
                                          ),
                                          onChanged: widget.action == 'add' || widget.action == 'edit' ? (value) {
                                            setState(() {
                                              currentS.currency = value ?? '';
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

                        if(widget.sub == 'saving')
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
                                          value: currentS.category?.id == '' ?
                                            categoryController.categories.firstWhere((category) => !category.isDeleted).id :
                                            currentS.category?.id == '' ?
                                              null :
                                              currentS.category!.subId == null ?
                                                categoryController.categories.where((category) => category.isDeleted == false).toList().expand((category) {
                                                  List<DropdownMenuItem<String>> items = [
                                                    DropdownMenuItem(
                                                      value: category.id,
                                                      child: Text(category.name),
                                                    ),
                                                  ];
                                                  
                                                  return items;
                                                }).toList().any((category) => category.value == currentS.category?.id) ?
                                                  currentS.category?.id :
                                                  categoryController.categories.firstWhere((category) => !category.isDeleted).id :
                                                categoryController.categories.where((category) => category.isDeleted == false).toList().expand((category) {
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
                                                }).toList().any((category) => category.value == '${currentS.category?.id}|${currentS.category?.subId}') ?
                                                  '${currentS.category?.id}|${currentS.category?.subId}' :
                                                  categoryController.categories.firstWhere((category) => !category.isDeleted).id,
                                          items: categoryController.categories.where((category) => category.isDeleted == false).toList().expand((category) {
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
                                              currentS.category = Category(
                                                id: (value ?? '').contains('|') ? (value ?? '').split('|')[0] : value ?? '',
                                                subId: (value ?? '').contains('|') ? int.parse((value ?? '').split('|')[1]) : null
                                              );
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

                        if(widget.sub == 'record')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 17.5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    "Tabungan",
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
                                          value: savingId == '' ?
                                            savingController.savings.firstWhere((saving) => !saving.isDeleted).id :
                                            savingId,
                                          items: [
                                            ...savingController.savings.where((saving) => saving.isDeleted == true && saving.id == savingId).toList().map((saving) {
                                              return DropdownMenuItem(
                                                value: saving.id,
                                                child: Text(saving.name),
                                              );
                                            }).toList(),
                                            ...savingController.savings.where((saving) => saving.isDeleted == false).toList().map((saving) {
                                              return DropdownMenuItem(
                                                value: saving.id,
                                                child: Text(saving.name),
                                              );
                                            }).toList(),
                                          ],
                                          style: TextStyle(
                                            fontSize: semiVerySmall,
                                            color: greyMinusTwo
                                          ),
                                          onChanged: widget.action == 'add' || widget.action == 'edit' ? (value) {
                                            setState(() {
                                              savingId = value ?? '';
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

                        if(widget.sub == 'record')
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
                                          value: currentR.accountId == '' ?
                                            accountController.accounts.firstWhere((account) => !account.isDeleted).id :
                                            currentR.accountId,
                                          items: [
                                            ...accountController.accounts.where((account) => account.isDeleted == true && account.id == (currentR.typeId == 0 ? currentR.accountId : currentR.accountId)).toList().map((account) {
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
                                              currentR.accountId = value ?? '';
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

                        Padding(
                          padding: const EdgeInsets.only(bottom: 17.5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  widget.sub == 'saving' ? 'Target Terkumpul' : "Tanggal",
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
                                    initialDate: widget.sub == 'saving' ? currentS.dueDate?.toDate().toUtc().add(Duration(hours: 7)) : currentR.date?.toDate().toUtc().add(Duration(hours: 7)),
                                    firstDate: DateTime(2010, 1, 1),
                                    lastDate: DateTime(2100, 1, 1),
                                  );

                                  if (pickedDate != null) {
                                    Timestamp timestamp = Timestamp.fromDate(pickedDate);
                                    setState(() {
                                      if(widget.sub == 'saving') currentS.dueDate = timestamp;
                                      if(widget.sub == 'record') currentR.date = timestamp;
                                    });
                                  }
                                } : null,
                                style: TextStyle(
                                  fontSize: semiVerySmall
                                ),
                                decoration: InputDecoration(
                                  hintText: DateFormat('dd MMMM yyyy', 'id_ID').format(widget.sub == 'saving' ? currentS.dueDate!.toDate().toUtc().add(Duration(hours: 7)) : currentR.date!.toDate().toUtc().add(Duration(hours: 7))),
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

                        if(widget.sub == 'saving')
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
                                      currentS.note = value;
                                    });
                                  },
                                  initialValue: currentS.note,
                                  style: TextStyle(
                                    fontSize: semiVerySmall
                                  ),
                                  decoration: InputDecoration(
                                    hintText: widget.action == 'view' ? savingController.saving?.note : 'Catatan',
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

            AllPadding(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: widget.action == 'view' ? null : OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: widget.action == 'add' || widget.action == 'edit' ? mainBlueMinusTwo : Colors.transparent,
                    side: BorderSide(color: widget.action == 'add' || widget.action == 'edit' ? Colors.transparent : mainBlueMinusTwo),
                    padding: EdgeInsets.all(widget.action == 'add' || widget.action == 'edit' ? 15 : 5)
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
                    SavingModel dataS = currentS;
                    Record dataR = currentR;
                    Map<String, dynamic> result = {};

                    print('savingId');
                    print(savingId);
                    print(currentR.accountId);
                    print(dataR.accountId);
                    
                    if(widget.action == 'add') {
                      if(widget.sub == 'record') dataR.typeId = oneSubtabController.selectedTab.value;

                      if(widget.sub == 'saving') result = await savingService.createSaving(user?.uid ?? '', dataS);
                      if(widget.sub == 'record') result = await savingService.createRecord(user?.uid ?? '', savingId, dataR);
                    } else if(widget.action == 'edit') {
                      if(widget.sub == 'record') dataR.typeId = oneSubtabController.selectedTab.value;
                      
                      if(widget.sub == 'saving') result = await savingService.updateSaving(user?.uid ?? '', widget.id, dataS);
                      if(widget.sub == 'record') result = await savingService.updateRecord(user?.uid ?? '', savingId, widget.subIndex, dataR);
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