import 'package:exinflow/controllers/account.dart';
import 'package:exinflow/controllers/category.dart';
import 'package:exinflow/controllers/credit.dart';
import 'package:exinflow/controllers/user.dart';
import 'package:exinflow/models/common.dart';
import 'package:exinflow/widgets/alert.dart';
import 'package:exinflow/widgets/padding.dart';
import 'package:exinflow/widgets/subtab.dart';
import 'package:flutter/material.dart';
import 'package:exinflow/widgets/top_bar.dart';
import 'package:exinflow/constants/constants.dart';
import 'package:exinflow/constants/data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:exinflow/services/transaction.dart';
import 'package:exinflow/services/currency.dart';
import 'package:exinflow/controllers/transaction.dart';
import 'package:exinflow/controllers/subtab.dart';
import 'package:exinflow/controllers/currency.dart';
import 'package:exinflow/models/transaction.dart';
import 'package:collection/collection.dart';
import 'dart:async'; 

// List
class Transactions extends StatefulWidget {
  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  final user = FirebaseAuth.instance.currentUser;
  final TransactionService transactionService = TransactionService();
  final CurrencyService currencyService = CurrencyService();
  final TransactionController transactionController = Get.find<TransactionController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final AccountController accountController = Get.find<AccountController>();
  final CreditController creditController = Get.find<CreditController>();
  final AllSubtabController allSubtabController = Get.find<AllSubtabController>();
  final UserController userController = Get.find<UserController>();
  final CurrencyController currencyController = Get.find<CurrencyController>();
  late TabController transactionsTabController;
  late StreamSubscription<int> selectedTabSubscription;

  final List<Map> tabs = [
    {
      "tab": "Semua",
      "title": "Semua Transaksi"
    },
    // {
    //   "tab": "Templat",
    //   "title": "Templat Transaksi"
    // },
    {
      "tab": "Berulang",
      "title": "Transaksi Berulang"
    },
  ];

  @override
  void initState() {
    super.initState();
    Get.delete<TabController>();
    transactionsTabController = Get.put(TabController(length: tabs.length, vsync: Scaffold.of(context)));
    selectedTabSubscription = allSubtabController.selectedTab.listen((index) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        transactionsTabController.animateTo(index);
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      allSubtabController.changeTab(0);
    });
  }

  @override
  void dispose() {
    selectedTabSubscription.cancel();
    Get.delete<TabController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: TopBar(
          id: '',
          title: "Transaksi",
          menu: "Transaksi",
          page: "All",
          type: '',
          from: '',
          // subtype: allSubtabController.selectedTab.value == 0 ? 'transaction' : allSubtabController.selectedTab.value == 1 ? 'template' : 'plan',
          subtype: allSubtabController.selectedTab.value == 0 ? 'transaction' : 'plan',
          subIndex: -1
        ),

        body: SingleChildScrollView(
          child: AllPadding(
            child: Obx(() {
              return Column(
                children: [
                  Subtab(tabs: tabs, type: 'all', disabled: false, controller: transactionsTabController),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      children: [
                        Obx(() {
                          return Text(
                            tabs[allSubtabController.selectedTab.value]['title'],
                            style: TextStyle(
                              fontSize: regular
                            ),
                          );
                        })
                      ],
                    ),
                  ),

                  StreamBuilder<QuerySnapshot>(
                    // stream: FirebaseFirestore.instance.collection(allSubtabController.selectedTab.value == 0 ? 'Transactions' : allSubtabController.selectedTab.value == 1 ? 'Transaction_Templates' : 'Transaction_Plans').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).snapshots(),
                    stream: FirebaseFirestore.instance.collection(allSubtabController.selectedTab.value == 0 ? 'Transactions' : 'Transaction_Plans').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).orderBy('Created_At', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text("Error");
                      }
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Text('');
                      }

                      if (snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            'Belum ada transaksi',
                            style: TextStyle(
                              fontSize: tiny,
                              color: greyMinusTwo
                            ),
                          )
                        );
                      }

                      var check = null;
                      check = snapshot.data!.docs[0];
                      var groupedItems;
                      String mainCurrency = userController.user?.mainCurrency ?? '';

                      if(allSubtabController.selectedTab.value == 0 && check.data()!.containsKey('Date')) {
                        var docs = snapshot.data!.docs;
                        groupedItems = groupBy(docs, (doc) {
                          DateTime dateTime = doc['Date'].toDate().toUtc().add(Duration(hours: 7));
                          String formattedDate = DateFormat('d MMMM yyyy', 'id_ID').format(dateTime);
                          return formattedDate;
                        });

                        var sortedGroupedItems = Map.fromEntries(
                          groupedItems.entries.toList()
                          ..sort((a, b) {
                            DateTime dateA = DateFormat('d MMMM yyyy', 'id_ID').parse(a.key);
                            DateTime dateB = DateFormat('d MMMM yyyy', 'id_ID').parse(b.key);
                            return dateB.compareTo(dateA);
                          })
                        );

                        groupedItems = sortedGroupedItems;
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: allSubtabController.selectedTab.value == 0 && check.data()!.containsKey('Date') ? groupedItems.length : snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var doc = null;
                          doc = snapshot.data!.docs[index];

                          Future<Map<String, dynamic>> conversionRates = currencyService.conversionRate(mainCurrency, currencyController.usedCurrencies ?? [], allSubtabController.selectedTab.value == 0 && doc.data()!.containsKey('Date') ? DateFormat('yyyy-MM-dd').format(DateFormat('d MMMM yyyy', 'id_ID').parse(groupedItems.keys.elementAt(index))) : 'now');
                          
                          return FutureBuilder<Map<String, dynamic>>(
                            future: conversionRates,
                            builder: (context, futureSnapshot) {
                              if (futureSnapshot.hasError) {
                                return Text("Error fetching conversion rates");
                              }
                              if (!futureSnapshot.hasData || futureSnapshot.data == null) {
                                return Text(
                                  '',
                                  style: TextStyle(
                                    color: mainBlue,
                                    fontSize: semiLarge
                                  )
                                );
                              }

                              var rates = futureSnapshot.data!['rates'];

                              double total = 0;
                          
                              if(allSubtabController.selectedTab.value == 0 && check.data()!.containsKey('Date')) {
                                for (var doc in groupedItems[groupedItems.keys.elementAt(index)]) {
                                  String currency = accountController.accounts.value.any((account) => account.id == (doc['Account_Id']['Destination'] ?? doc['Account_Id']['Source'])) ? accountController.accounts.value.firstWhere((account) => account.id == (doc['Account_Id']['Destination'] ?? doc['Account_Id']['Source'])).currency : creditController.credits.value.firstWhere((credit) => credit.id == (doc['Account_Id']['Destination'] ?? doc['Account_Id']['Source'])).currency;
                                  int type = doc['Type_Id'];
                                  double amount = type == 3 ? doc['Fee']?.toDouble() ?? 0.0 : doc['Amount']?.toDouble() ?? 0.0;
                                  
                                  if(currency == mainCurrency) {
                                    if(type == 0) {
                                      total -= amount;
                                    }
                                    if(type == 1) {
                                      total += amount;
                                    }
                                  } else {
                                    if(type == 0) {
                                      total -= (amount * rates[currency]);
                                    }
                                    if(type == 1) {
                                      total += (amount * rates[currency]);
                                    }
                                  }
                                }
                              }
                              var absTotal = total.abs();

                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                margin: EdgeInsets.only(bottom: (index + 1 != (allSubtabController.selectedTab.value == 0 && check.data()!.containsKey('Date') ? groupedItems.length : snapshot.data!.docs.length)) ? 10 : 0),
                                decoration: BoxDecoration(
                                  color: greyMinusFive,
                                  borderRadius: borderRadius,
                                ),
                                child: Column(
                                  children: [
                                    if(allSubtabController.selectedTab.value == 0 && check.data()!.containsKey('Date'))
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 20),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              groupedItems.keys.elementAt(index)
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '${total < 0 ? '-' : ''}${currencies.firstWhere((currency) => currency['ISO_Code'] == userController.user?.mainCurrency)['Symbol'] ?? ''}',
                                                  style: TextStyle(
                                                    color: greyMinusTwo,
                                                    fontSize: tiny
                                                  ),
                                                ),
                                                Text(
                                                  NumberFormat('#,##0.###', 'de_DE').format(absTotal),
                                                  style: TextStyle(
                                                    color: greyMinusTwo,
                                                    fontSize: tiny
                                                  ),
                                                ),
                                              ]
                                            )
                                          ],
                                        ),
                                      ),
                                    if(allSubtabController.selectedTab.value == 0 && check.data()!.containsKey('Date'))
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: groupedItems[groupedItems.keys.elementAt(index)].length,
                                        itemBuilder: (context, subIndex) {
                                          return InkWell(
                                            onTap: () async {
                                              transactionController.setTransaction(
                                                TransactionModel(
                                                  id: groupedItems[groupedItems.keys.elementAt(index)][subIndex].id,
                                                  amount: groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Amount'].toDouble(),
                                                  category: groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Category'] == null ? null : Category(
                                                    id: groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Category']['Id'],
                                                    subId: groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Category']['Sub_Id']
                                                  ),
                                                  accountId: Account(
                                                    destination: groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Account_Id']['Destination'],
                                                    source: groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Account_Id']['Source']
                                                  ),
                                                  typeId: groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Type_Id'],
                                                  fee: groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Fee'],
                                                  note: groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Note'],
                                                  date: groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Date'],
                                                )
                                              );
                                              context.push('/manage/transactions/transaction/${groupedItems[groupedItems.keys.elementAt(index)][subIndex].id}?action=view');
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(bottom: 15),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 50,
                                                        height: 50,
                                                        margin: EdgeInsets.only(right: 15),
                                                        decoration: BoxDecoration(
                                                          borderRadius: borderRadius,
                                                          color: Color(int.parse('FF${groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Category'] != null ? groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Category']['Sub_Id'] != null ? categoryController.categories.value.firstWhere((category) => category.id == groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Category']['Id']).color : categoryController.categories.value.firstWhere((category) => category.id == groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Category']['Id']).color : '0f667b'}', radix: 16))
                                                        ),
                                                        child: Icon(
                                                          groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Category'] != null ? icons[groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Category']['Sub_Id'] != null ? categoryController.categories.value.firstWhere((category) => category.id == groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Category']['Id']).subs![groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Category']['Sub_Id']].icon : categoryController.categories.value.firstWhere((category) => category.id == groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Category']['Id']).icon] : Icons.loop_rounded,
                                                          color: Colors.white,
                                                          size: 25
                                                        )
                                                      ),
                                          
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Category'] != null ?
                                                              groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Category']['Sub_Id'] != null ?
                                                                categoryController.categories.value.firstWhere((category) => category.id == groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Category']['Id']).subs![groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Category']['Sub_Id']].name :
                                                                categoryController.categories.value.firstWhere((category) => category.id == groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Category']['Id']).name :
                                                              'Transfer',
                                                            style: TextStyle(
                                                              fontSize: small
                                                            )
                                                          ),
                                                      
                                                          Text(
                                                            groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Account_Id']['Source'] != null && groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Account_Id']['Destination'] != null ?
                                                              '${accountController.accounts.value.firstWhere((account) => account.id == groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Account_Id']['Source']).name} > ${accountController.accounts.value.firstWhere((account) => account.id == groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Account_Id']['Destination']).name}' :
                                                              groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Account_Id']['Source'] == null ?
                                                                accountController.accounts.value.firstWhere((account) => account.id == groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Account_Id']['Destination']).name :
                                                                accountController.accounts.value.any((account) => account.id == groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Account_Id']['Source']) ?
                                                                  accountController.accounts.value.firstWhere((account) => account.id == groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Account_Id']['Source']).name :
                                                                  creditController.credits.value.firstWhere((credit) => credit.id == groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Account_Id']['Source']).provider,
                                                            style: TextStyle(
                                                              fontSize: verySmall,
                                                              color: greyMinusThree
                                                            )
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                          
                                                  Row(
                                                    children: [
                                                      Text(
                                                        groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Account_Id']['Source'] == null ?
                                                          currencies.firstWhere((currency) => currency['ISO_Code'] == accountController.accounts.value.firstWhere((account) => account.id == groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Account_Id']['Destination']).currency)['Symbol'] ?? '' :
                                                          accountController.accounts.value.any((account) => account.id == groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Account_Id']['Source']) ?
                                                            currencies.firstWhere((currency) => currency['ISO_Code'] == accountController.accounts.value.firstWhere((account) => account.id == groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Account_Id']['Source']).currency)['Symbol'] ?? '' :
                                                            currencies.firstWhere((currency) => currency['ISO_Code'] == creditController.credits.value.firstWhere((credit) => credit.id == groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Account_Id']['Source']).currency)['Symbol'] ?? '',
                                                        style: TextStyle(
                                                          fontSize: semiVerySmall,
                                                          fontWeight: FontWeight.w500,
                                                          color: groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Type_Id'] == 0 ? redPlusOne : groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Type_Id'] == 1 ? greenPlusOne : mainBlue
                                                        )
                                                      ),
                                                      Text(
                                                        NumberFormat('#,##0.###', 'de_DE').format(groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Amount']),
                                                        style: TextStyle(
                                                          fontSize: semiVerySmall,
                                                          fontWeight: FontWeight.w500,
                                                          color: groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Type_Id'] == 0 ? redPlusOne : groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Type_Id'] == 1 ? greenPlusOne : mainBlue
                                                        )
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            )
                                          );
                                        }
                                      ),

                                    // if(allSubtabController.selectedTab.value == 1 && doc.data()!.containsKey('Name'))
                                    //   InkWell(
                                    //     onTap: () async {
                                    //       transactionController.setTransactionTemplate(
                                    //         TransactionTemplateModel(
                                    //           id: doc.id,
                                    //           amount: doc['Amount'].toDouble(),
                                    //           category: Category(
                                    //             id: doc['Category']['Id'],
                                    //             subId: doc['Category']['Sub_Id']
                                    //           ),
                                    //           accountId: Account(
                                    //             destination: doc['Account_Id']['Destination'],
                                    //             source: doc['Account_Id']['Source']
                                    //           ),
                                    //           typeId: doc['Type_Id'],
                                    //           fee: doc['Fee'],
                                    //           note: doc['Note'],
                                    //           name: doc['Name'],
                                    //         )
                                    //       );
                                    //       context.push('/manage/transactions/template/${doc.id}?action=view');
                                    //     },
                                    //     child: Padding(
                                    //       padding: const EdgeInsets.only(bottom: 5),
                                    //       child: Row(
                                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //         children: [
                                    //           Row(
                                    //             children: [
                                    //               Container(
                                    //                 width: 50,
                                    //                 height: 50,
                                    //                 margin: EdgeInsets.only(right: 15),
                                    //                 decoration: BoxDecoration(
                                    //                   borderRadius: borderRadius,
                                    //                   color: Color(int.parse('FF${doc['Category'] != null ? doc['Category']['Sub_Id'] != null ? categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).color : categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).color : '0f667b'}', radix: 16))
                                    //                 ),
                                    //                 child: Icon(
                                    //                   doc['Category'] != null ? icons[doc['Category']['Sub_Id'] != null ? categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).subs![doc['Category']['Sub_Id']].icon : categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).icon] : Icons.loop_rounded,
                                    //                   color: Colors.white,
                                    //                   size: 25
                                    //                 )
                                    //               ),
                                      
                                    //               Column(
                                    //                 crossAxisAlignment: CrossAxisAlignment.start,
                                    //                 children: [
                                    //                   Text(
                                    //                     doc['Name'],
                                    //                     style: TextStyle(
                                    //                       fontSize: small
                                    //                     )
                                    //                   ),
                                                  
                                    //                   Text(
                                    //                     doc['Account_Id']['Source'] != null && doc['Account_Id']['Destination'] != null ? '${accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Source']).name} > ${accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Destination']).name}' : doc['Account_Id']['Source'] == null ? accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Destination']).name : accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Source']).name,
                                    //                     style: TextStyle(
                                    //                       fontSize: verySmall,
                                    //                       color: greyMinusThree
                                    //                     )
                                    //                   )
                                    //                 ],
                                    //               ),
                                    //             ],
                                    //           ),
                                      
                                    //           Row(
                                    //             children: [
                                    //               Text(
                                    //                 doc['Account_Id']['Source'] == null ? currencies.firstWhere((currency) => currency['ISO_Code'] == accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Destination']).currency)['Symbol'] ?? '' : currencies.firstWhere((currency) => currency['ISO_Code'] == accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Source']).currency)['Symbol'] ?? '',
                                    //                 style: TextStyle(
                                    //                   fontSize: semiVerySmall,
                                    //                   fontWeight: FontWeight.w500,
                                    //                   color: doc['Type_Id'] == 0 ? redPlusOne : doc['Type_Id'] == 1 ? greenPlusOne : mainBlue
                                    //                 )
                                    //               ),
                                    //               Text(
                                    //                 NumberFormat('#,##0.###', 'de_DE').format(doc['Amount']),
                                    //                 style: TextStyle(
                                    //                   fontSize: semiVerySmall,
                                    //                   fontWeight: FontWeight.w500,
                                    //                   color: doc['Type_Id'] == 0 ? redPlusOne : doc['Type_Id'] == 1 ? greenPlusOne : mainBlue
                                    //                 )
                                    //               ),
                                    //             ],
                                    //           ),
                                    //         ],
                                    //       )
                                    //     )
                                    //   ),

                                    // if(allSubtabController.selectedTab.value == 2 && doc.data()!.containsKey('Is_Active'))
                                    if(allSubtabController.selectedTab.value == 1 && doc.data()!.containsKey('Is_Active'))
                                      InkWell(
                                        onTap: () {
                                          transactionController.setTransactionPlan(
                                            TransactionPlanModel(
                                              id: doc.id,
                                              amount: doc['Amount'].toDouble(),
                                              category: Category(
                                                id: doc['Category']['Id'],
                                                subId: doc['Category']['Sub_Id']
                                              ),
                                              accountId: Account(
                                                destination: doc['Account_Id']['Destination'],
                                                source: doc['Account_Id']['Source']
                                              ),
                                              typeId: doc['Type_Id'],
                                              fee: doc['Fee'],
                                              note: doc['Note'],
                                              name: doc['Name'],
                                              isActive: doc['Is_Active'],
                                              frequency: Frequency(
                                                repeat: doc['Frequency']['Repeat'],
                                                recurrence: Recurrence(
                                                  count: doc['Frequency']['Recurrence']['Count'],
                                                  timeUnitId: doc['Frequency']['Recurrence']['Time_Unit_Id'],
                                                ),
                                                startDate: doc['Frequency']['Start_Date'],
                                              ),
                                            )
                                          );
                                          context.push('/manage/transactions/plan/${doc.id}?action=view');
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 5),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    width: 50,
                                                    height: 50,
                                                    margin: EdgeInsets.only(bottom: 15),
                                                    decoration: BoxDecoration(
                                                      borderRadius: borderRadius,
                                                      color: Color(int.parse('FF${doc['Category'] != null ? doc['Category']['Sub_Id'] != null ? categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).color : categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).color : '0f667b'}', radix: 16))
                                                    ),
                                                    child: Icon(
                                                      doc['Category'] != null ? icons[doc['Category']['Sub_Id'] != null ? categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).subs![doc['Category']['Sub_Id']].icon : categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).icon] : Icons.loop_rounded,
                                                      color: Colors.white,
                                                      size: 25
                                                    )
                                                  ),
                                      
                                                  Switch(
                                                    value: doc['Is_Active'],
                                                    onChanged: (value) async {
                                                      await transactionService.changeTransactionPlanActiveStatus(user?.uid ?? '', doc.id, doc['Is_Active']);
                                                    },
                                                    activeTrackColor: mainBlueMinusFour,
                                                    activeColor: mainBlue,
                                                  ),
                                                ],
                                              ),
                                      
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        doc['Name'] ?? '',
                                                        style: TextStyle(
                                                          fontSize: small
                                                        )
                                                      ),
                                                  
                                                      Text(
                                                        doc['Account_Id']['Source'] != null && doc['Account_Id']['Destination'] != null ? '${accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Source']).name} > ${accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Destination']).name}' : doc['Account_Id']['Source'] == null ? accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Destination']).name : accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Source']).name,
                                                        style: TextStyle(
                                                          fontSize: verySmall,
                                                          color: greyMinusThree
                                                        )
                                                      )
                                                    ],
                                                  ),
                                      
                                                  Row(
                                                    children: [
                                                      Text(
                                                        doc['Account_Id']['Source'] == null ? currencies.firstWhere((currency) => currency['ISO_Code'] == accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Destination']).currency)['Symbol'] ?? '' : currencies.firstWhere((currency) => currency['ISO_Code'] == accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Source']).currency)['Symbol'] ?? '',
                                                        style: TextStyle(
                                                          fontSize: small,
                                                          fontWeight: FontWeight.w500,
                                                          color: doc['Type_Id'] == 0 ? redPlusOne : doc['Type_Id'] == 1 ? greenPlusOne : mainBlue
                                                        )
                                                      ),
                                                      Text(
                                                        NumberFormat('#,##0.###', 'de_DE').format(doc['Amount']),
                                                        style: TextStyle(
                                                          fontSize: small,
                                                          fontWeight: FontWeight.w500,
                                                          color: doc['Type_Id'] == 0 ? redPlusOne : doc['Type_Id'] == 1 ? greenPlusOne : mainBlue
                                                        )
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              
                                              Padding(
                                                padding: const EdgeInsets.only(top: 10),
                                                child: Text(
                                                  doc['Frequency']['Repeat'] == false ? 'Tanggal ${DateFormat('dd MMMM yyyy', 'id_ID').format(doc['Created_At'].toDate().toUtc().add(Duration(hours: 7)))}' : 'Setiap ${doc['Frequency']['Recurrence']['Count']} ${timeUnits[doc['Frequency']['Recurrence']['Time_Unit_Id']]} sekali',
                                                  style: TextStyle(
                                                    fontSize: tiny,
                                                    color: greyMinusTwo
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      )
                                  ],
                                )
                              );
                            }
                          );
                        }
                      );
                    }
                  ),
                ],
              );
            }),
          ),
        ),
      );
    });
  }
}