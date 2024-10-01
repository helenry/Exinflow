import 'package:exinflow/controllers/account.dart';
import 'package:exinflow/controllers/category.dart';
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
import 'package:exinflow/services/credit.dart';
import 'package:exinflow/services/currency.dart';
import 'package:exinflow/controllers/credit.dart';
import 'package:exinflow/controllers/subtab.dart';
import 'package:exinflow/controllers/currency.dart';
import 'package:exinflow/models/credit.dart';
import 'package:collection/collection.dart';
import 'dart:async'; 

// List
class Credits extends StatefulWidget {
  @override
  State<Credits> createState() => _CreditsState();
}

class _CreditsState extends State<Credits> {
  final user = FirebaseAuth.instance.currentUser;
  final CreditService creditService = CreditService();
  final CurrencyService currencyService = CurrencyService();
  final CreditController creditController = Get.find<CreditController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final AccountController accountController = Get.find<AccountController>();
  final AllSubtabController allSubtabController = Get.find<AllSubtabController>();
  final UserController userController = Get.find<UserController>();
  final CurrencyController currencyController = Get.find<CurrencyController>();
  late TabController creditsTabController;
  late StreamSubscription<int> selectedTabSubscription;

  final List<Map> tabs = [
    {
      "tab": "Penyedia",
      "title": "Penyedia Kredit"
    },
    {
      "tab": "Tagihan",
      "title": "Tagihan Kredit"
    },
    // {
    //   "tab": "Cicilan",
    //   "title": "Cicilan Kredit"
    // },
  ];

  @override
  void initState() {
    super.initState();
    Get.delete<TabController>();
    creditsTabController = Get.put(TabController(length: tabs.length, vsync: Scaffold.of(context)));

    selectedTabSubscription = allSubtabController.selectedTab.listen((index) {
      creditsTabController.animateTo(index);
    });

    allSubtabController.changeTab(0);
  }

  @override
  void dispose() {
    selectedTabSubscription.cancel();
    Get.delete<TabController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        id: '',
        title: "Kredit",
        menu: "Kredit",
        page: "All",
        type: '',
        from: '',
        subtype: allSubtabController.selectedTab.value == 0 ? 'provider' : 'bill',
        subIndex: -1
      ),

      body: SingleChildScrollView(
        child: AllPadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Limit',
                      style: TextStyle(
                        fontSize: regular,
                        color: greyMinusThree
                      )
                    ),
                    Text(
                      'Rp${NumberFormat('#,##0.###', 'de_DE').format(8000000)}',
                      style: TextStyle(
                        fontSize: semiMedium,
                        color: greyMinusTwo
                      )
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Terpakai',
                                style: TextStyle(
                                  fontSize: semiVerySmall,
                                  color: greyMinusThree
                                )
                              ),
                              Text(
                                'Rp${NumberFormat('#,##0.###', 'de_DE').format(5000000)}',
                                style: TextStyle(
                                  fontSize: small,
                                  color: greyMinusTwo
                                )
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Sisa',
                                style: TextStyle(
                                  fontSize: semiVerySmall,
                                  color: greyMinusThree
                                )
                              ),
                              Text(
                                'Rp${NumberFormat('#,##0.###', 'de_DE').format(3000000)}',
                                style: TextStyle(
                                  fontSize: small,
                                  color: greyMinusTwo
                                )
                              ),
                            ],
                          )
                        ]
                      ),
                    ),

                    ClipRRect(
                      borderRadius: borderRadius,
                      child: LinearProgressIndicator(
                        value: 5000000 / 8000000,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(mainBlue),
                      ),
                    )
                  ]
                )
              ),

              Obx(() {
                return Column(
                  children: [
                    Subtab(tabs: tabs, type: 'all', disabled: false, controller: creditsTabController),
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
                      stream: FirebaseFirestore.instance.collection(allSubtabController.selectedTab.value == 0 ? 'Credits' : 'Transactions').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text("Error");
                        }
                        if (!snapshot.hasData || snapshot.data == null) {
                          return Text('');
                        }

                        String mainCurrency = userController.user?.mainCurrency ?? '';
                        var check = null;
                        check = snapshot.data!.docs[0];
                        var groupedItems;

                        if(allSubtabController.selectedTab.value == 1 && check.data()!.containsKey('Date')) {
                          var docs = snapshot.data!.docs;
                          groupedItems = groupBy(docs, (doc) {
                            DateTime dateTime = doc['Date'].toDate().toUtc().add(Duration(hours: 7));
                            String formattedMonth = DateFormat('yyyy', 'id_ID').format(dateTime);
                            return formattedMonth;
                          });
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: allSubtabController.selectedTab.value == 1 && check.data()!.containsKey('Date') ? groupedItems.length : snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var doc = null;
                            doc = snapshot.data!.docs[index];

                            // Future<Map<String, dynamic>> conversionRates = currencyService.conversionRate(mainCurrency, currencyController.usedCurrencies ?? [], allSubtabController.selectedTab.value == 1 && doc.data()!.containsKey('Date') ? DateFormat('yyyy-MM-dd').format(DateFormat('d MMMM yyyy', 'id_ID').parse(groupedItems.keys.elementAt(index))) : 'now');
                            Future<Map<String, dynamic>> conversionRates = currencyService.conversionRate(mainCurrency, currencyController.usedCurrencies ?? [], 'now');

                            return Column(
                              children: [
                                if(allSubtabController.selectedTab.value == 0 && check.data()!.containsKey('Color'))
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      var filteredDocs = snapshot.data!.docs.toList();
                                      var doc = filteredDocs[index];
                                
                                      return InkWell(
                                        onTap: () {
                                          creditController.setCredit(
                                            CreditModel(
                                              id: doc.id,
                                              provider: doc['Provider'],
                                              limitAmount: doc['Limit_Amount'].toDouble(),
                                              currency: doc['Currency'],
                                              typeId: doc['Type_Id'],
                                              limits: null,
                                              installments: null,
                                              dueDate: doc['Due_Date'],
                                              cutOffDate: doc['Cut_Off_Date'],
                                              icon: doc['Icon'],
                                              color: doc['Color'].toString(),
                                              isDeleted: false
                                            )
                                          );
                                          context.push('/manage/credits/credit/${doc.id}?action=view');
                                        },
                                        child: Container(
                                          padding: EdgeInsets.only(top: 15, right: 15, left: 15, bottom: 25),
                                          margin: EdgeInsets.only(bottom: index + 1 != snapshot.data!.docs.length ? 10 : 0),
                                          decoration: BoxDecoration(
                                            color: greyMinusFive,
                                            borderRadius: borderRadius,
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 60,
                                                    height: 60,
                                                    margin: EdgeInsets.only(bottom: 10),
                                                    decoration: BoxDecoration(
                                                      borderRadius: borderRadius,
                                                      color: Color(int.parse('FF${doc['Color']}', radix: 16))
                                                    ),
                                                    child: Icon(
                                                      icons[doc['Icon']],
                                                      color: Colors.white,
                                                      size: 32.5
                                                    )
                                                  ),
                                                  OutlinedButton(
                                                    onPressed: () {
                                                      showModalBottomSheet(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return Container(
                                                            padding: EdgeInsets.all(16),
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                ListTile(
                                                                  leading: Icon(Icons.edit),
                                                                  title: Text('Ubah'),
                                                                  onTap: () {
                                                                    Navigator.pop(context);
                                
                                                                    creditController.setCredit(
                                                                      CreditModel(
                                                                        id: doc.id,
                                                                        provider: doc['Provider'],
                                                                        limitAmount: doc['Limit_Amount'].toDouble(),
                                                                        currency: doc['Currency'],
                                                                        typeId: doc['Type_Id'],
                                                                        limits: null,
                                                                        installments: null,
                                                                        dueDate: doc['Due_Date'],
                                                                        cutOffDate: doc['Cut_Off_Date'],
                                                                        icon: doc['Icon'],
                                                                        color: doc['Color'].toString(),
                                                                        isDeleted: false
                                                                      )
                                                                    );
                                
                                                                    context.push('/manage/credits/credit/${doc.id}?action=edit&from=dots');
                                                                  },
                                                                ),
                                                                if(snapshot.data!.docs.length != 1)
                                                                  ListTile(
                                                                    leading: Icon(Icons.delete),
                                                                    title: Text('Hapus'),
                                                                    onTap: () async {
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
                                                                      
                                                                        Map<String, dynamic> result = await creditService.deleteCredit(user?.uid ?? '', doc.id);
                                
                                                                        creditController.setCredit(
                                                                          CreditModel(
                                                                            id: '',
                                                                            provider: '',
                                                                            limitAmount: 0,
                                                                            currency: '',
                                                                            typeId: 0,
                                                                            limits: null,
                                                                            installments: null,
                                                                            dueDate: 0,
                                                                            cutOffDate: 0,
                                                                            icon: '',
                                                                            color: '',
                                                                            isDeleted: false
                                                                          )
                                                                        );                
                                                                      }
                                                                    },
                                                                  ),
                                                              ],
                                                            ),
                                                          );
                                                        }
                                                      );
                                                    },
                                                    style: OutlinedButton.styleFrom(
                                                      shape: CircleBorder(),
                                                      side: BorderSide(width: 1, color: greyMinusTwo),
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: Size(45, 45),
                                                    ),
                                                    child: Icon(
                                                      Icons.more_horiz_rounded,
                                                      color: greyMinusTwo,
                                                      size: 25
                                                    ),
                                                  )
                                                ],
                                              ),
                                        
                                              Text(
                                                doc['Provider'],
                                                style: TextStyle(
                                                  fontSize: semiMedium,
                                                  fontWeight: FontWeight.w500,
                                                  color: greyMinusTwo
                                                )
                                              ),
                                              Text(
                                                creditTypes[doc['Type_Id']],
                                                style: TextStyle(
                                                  fontSize: small,
                                                  color: greyMinusTwo
                                                )
                                              ),
                                              
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 10, top: 7.5),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "${currencies.firstWhere((currency) => currency["ISO_Code"] == doc['Currency'])['Symbol'] ?? ''}${NumberFormat('#,##0.###', 'de_DE').format(100000)}",
                                                      style: TextStyle(
                                                        fontSize: small,
                                                        color: greyMinusTwo
                                                      )
                                                    ),
                                                    Text(
                                                      "${currencies.firstWhere((currency) => currency["ISO_Code"] == doc['Currency'])['Symbol'] ?? ''}${NumberFormat('#,##0.###', 'de_DE').format(doc['Limit_Amount'] - 100000)}",
                                                      style: TextStyle(
                                                        fontSize: small,
                                                        color: greyMinusTwo
                                                      )
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              ClipRRect(
                                                borderRadius: borderRadius,
                                                child: LinearProgressIndicator(
                                                  value: 100000 / doc['Limit_Amount'],
                                                  backgroundColor: Colors.grey[300],
                                                  valueColor: AlwaysStoppedAnimation<Color>(Color(int.parse('FF${doc['Color']}', radix: 16))),
                                                ),
                                              ),
                                            ]
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                // if(allSubtabController.selectedTab.value == 1 && check.data()!.containsKey('Date'))
                                //   FutureBuilder<Map<String, dynamic>>(
                                //     future: conversionRates,
                                //     builder: (context, futureSnapshot) {
                                //       if (futureSnapshot.hasError) {
                                //         return Text("Error fetching conversion rates");
                                //       }
                                //       if (!futureSnapshot.hasData || futureSnapshot.data == null) {
                                //         return Text(
                                //           '',
                                //           style: TextStyle(
                                //             color: mainBlue,
                                //             fontSize: semiLarge
                                //           )
                                //         );
                                //       }

                                //       var rates = futureSnapshot.data!['rates'];

                                //       double total = 0;
                                  
                                //       if(allSubtabController.selectedTab.value == 1 && check.data()!.containsKey('Date')) {
                                //       }

                                //       return Container(
                                //         padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                //         margin: EdgeInsets.only(bottom: (index + 1 != (allSubtabController.selectedTab.value == 1 && check.data()!.containsKey('Date') ? groupedItems.length : snapshot.data!.docs.length)) ? 10 : 0),
                                //         decoration: BoxDecoration(
                                //           color: greyMinusFive,
                                //           borderRadius: borderRadius,
                                //         ),
                                //         child: Column(
                                //           children: [

                                //           ]
                                //         )
                                //       );
                                //     }
                                //   )
                              ]
                            );
                          }
                        );
                      }
                    )
                  ]
                );
              })
            ],
          )
        )
      )
    );
  }
}