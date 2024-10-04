import 'package:exinflow/controllers/account.dart';
import 'package:exinflow/controllers/category.dart';
import 'package:exinflow/controllers/user.dart';
import 'package:exinflow/controllers/saving.dart';
import 'package:exinflow/models/common.dart';
import 'package:exinflow/models/saving.dart';
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
class Savings extends StatefulWidget {
  @override
  State<Savings> createState() => _SavingsState();
}

class _SavingsState extends State<Savings> {
  final user = FirebaseAuth.instance.currentUser;
  final CreditService creditService = CreditService();
  final CurrencyService currencyService = CurrencyService();
  final CreditController creditController = Get.find<CreditController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final AccountController accountController = Get.find<AccountController>();
  final AllSubtabController allSubtabController = Get.find<AllSubtabController>();
  final UserController userController = Get.find<UserController>();
  final SavingController savingController = Get.find<SavingController>();
  final CurrencyController currencyController = Get.find<CurrencyController>();
  late TabController savingsTabController;
  late StreamSubscription<int> selectedTabSubscription;

  final List<Map> tabs = [
    {
      "tab": "Semua",
      "title": "Semua Tabungan"
    },
    {
      "tab": "Catatan",
      "title": "Catatan Tabungan"
    },
  ];

  @override
  void initState() {
    super.initState();
    Get.delete<TabController>();
    savingsTabController = Get.put(TabController(length: tabs.length, vsync: Scaffold.of(context)));

    selectedTabSubscription = allSubtabController.selectedTab.listen((index) {
      savingsTabController.animateTo(index);
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
    return Obx(() {
      return Scaffold(
        appBar: TopBar(
          id: '',
          title: "Tabungan",
          menu: "Tabungan",
          page: "All",
          type: '',
          from: '',
          subtype: allSubtabController.selectedTab.value == 0 ? 'saving' : 'record',
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
                        'Target',
                        style: TextStyle(
                          fontSize: regular,
                          color: greyMinusThree
                        )
                      ),
                      Row(
                        children: [
                          Text(
                            userController.user?.mainCurrency == '' ? '' : currencies.firstWhere((currency) => currency["ISO_Code"] == userController.user?.mainCurrency)['Symbol'] ?? '',
                            style: TextStyle(
                              color: greyMinusTwo,
                              fontSize: semiMedium
                            ),
                          ),

                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('Savings').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text("Error");
                              }
                              if (!snapshot.hasData || snapshot.data == null) {
                                return Text(
                                  '0',
                                  style: TextStyle(
                                    color: greyMinusTwo,
                                    fontSize: semiMedium
                                  )
                                );
                              }

                              String mainCurrency = userController.user?.mainCurrency ?? '';

                              Set<String> uniqueCurrencies = {};
                              for (var doc in snapshot.data!.docs) {
                                String currency = doc['Currency'];
                                if(currency != mainCurrency) {
                                  uniqueCurrencies.add(currency);
                                }
                              }
                              List<String> uniqueCurrenciesList = uniqueCurrencies.toList();

                              Future<Map<String, dynamic>> conversionRates = currencyService.conversionRate(mainCurrency, uniqueCurrenciesList, 'now');

                              return FutureBuilder<Map<String, dynamic>>(
                                future: conversionRates,
                                builder: (context, futureSnapshot) {
                                  if (futureSnapshot.hasError) {
                                    return Text("Error fetching conversion rates");
                                  }
                                  if (!futureSnapshot.hasData || futureSnapshot.data == null) {
                                    return Text(
                                      '0',
                                      style: TextStyle(
                                        color: greyMinusTwo,
                                        fontSize: semiMedium
                                      )
                                    );
                                  }

                                  var rates = futureSnapshot.data!['rates'];
                                  currencyController.setCurrencies(uniqueCurrenciesList);
                                  double total = 0;

                                  for (var doc in snapshot.data!.docs) {
                                    String currency = doc['Currency'] ?? '';
                                    double amount = doc['Target_Amount']?.toDouble() ?? 0.0;

                                    if(currency == mainCurrency) {
                                      total += amount;
                                    } else {
                                      total += (amount * rates[currency]);
                                    }
                                  }

                                  return Text(
                                    NumberFormat('#,##0.###', 'de_DE').format(total),
                                    style: TextStyle(
                                      color: greyMinusTwo,
                                      fontSize: semiMedium
                                    )
                                  );
                                }
                              );
                            },
                          )
                        ],
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
                                  'Tersimpan',
                                  style: TextStyle(
                                    fontSize: semiVerySmall,
                                    color: greyMinusThree
                                  )
                                ),
                                Row(
                                  children: [
                                    Text(
                                      userController.user?.mainCurrency == '' ? '' : currencies.firstWhere((currency) => currency["ISO_Code"] == userController.user?.mainCurrency)['Symbol'] ?? '',
                                      style: TextStyle(
                                        color: greyMinusTwo,
                                        fontSize: small
                                      ),
                                    ),
                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance.collection('Savings').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return Text("Error");
                                        }
                                        if (!snapshot.hasData || snapshot.data == null) {
                                          return Text(
                                            '0',
                                            style: TextStyle(
                                              color: greyMinusTwo,
                                              fontSize: small
                                            )
                                          );
                                        }

                                        var docs = snapshot.data!.docs;
                                        String mainCurrency = userController.user?.mainCurrency ?? '';
                                        Set<String> uniqueCurrencies = {};

                                        for (var doc in docs) {
                                          String currency = doc['Currency'];

                                          if(currency != mainCurrency) {
                                            uniqueCurrencies.add(currency);
                                          }
                                        }
                                        List<String> uniqueCurrenciesList = uniqueCurrencies.toList();

                                        Future<Map<String, dynamic>> conversionRates = currencyService.conversionRate(mainCurrency, uniqueCurrenciesList, 'now');

                                        return FutureBuilder<Map<String, dynamic>>(
                                          future: conversionRates,
                                          builder: (context, futureSnapshot) {
                                            if (futureSnapshot.hasError) {
                                              return Text("Error fetching conversion rates");
                                            }
                                            if (!futureSnapshot.hasData || futureSnapshot.data == null) {
                                              return Text(
                                                '0',
                                                style: TextStyle(
                                                  color: greyMinusTwo,
                                                  fontSize: small
                                                )
                                              );
                                            }

                                            var rates = futureSnapshot.data!['rates'];
                                            double total = 0;

                                            for (var doc in docs) {
                                              String currency = doc['Currency'];

                                              if(currency != mainCurrency) {
                                                uniqueCurrencies.add(currency);
                                              }

                                              if(doc['Records'] != null) {
                                                for (var record in doc['Records']) {
                                                  if(record['Is_Deleted'] == false) {
                                                    double amount = record['Amount']?.toDouble() ?? 0.0;

                                                    if(currency == mainCurrency) {
                                                      if(record['Type_Id'] == 0) total -= amount;
                                                      if(record['Type_Id'] == 1) total += amount;
                                                    } else {
                                                      if(record['Type_Id'] == 0) total -= (amount * rates[currency]);
                                                      if(record['Type_Id'] == 1) total += (amount * rates[currency]);
                                                    }
                                                  }
                                                }
                                              }
                                            }

                                            return Text(
                                              NumberFormat('#,##0.###', 'de_DE').format(total),
                                              style: TextStyle(
                                                color: greyMinusTwo,
                                                fontSize: small
                                              )
                                            );
                                          }
                                        );
                                      },
                                    )
                                  ],
                                )
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
                                Row(
                                  children: [
                                    Text(
                                      userController.user?.mainCurrency == '' ? '' : currencies.firstWhere((currency) => currency["ISO_Code"] == userController.user?.mainCurrency)['Symbol'] ?? '',
                                      style: TextStyle(
                                        color: greyMinusTwo,
                                        fontSize: small
                                      ),
                                    ),

                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance.collection('Savings').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return Text("Error");
                                        }
                                        if (!snapshot.hasData || snapshot.data == null) {
                                          return Text(
                                            '0',
                                            style: TextStyle(
                                              color: greyMinusTwo,
                                              fontSize: small
                                            )
                                          );
                                        }

                                        String mainCurrency = userController.user?.mainCurrency ?? '';

                                        Set<String> uniqueCurrencies = {};
                                        for (var doc in snapshot.data!.docs) {
                                          String currency = doc['Currency'];
                                          if(currency != mainCurrency) {
                                            uniqueCurrencies.add(currency);
                                          }
                                        }
                                        List<String> uniqueCurrenciesList = uniqueCurrencies.toList();

                                        Future<Map<String, dynamic>> conversionRates = currencyService.conversionRate(mainCurrency, uniqueCurrenciesList, 'now');

                                        return FutureBuilder<Map<String, dynamic>>(
                                          future: conversionRates,
                                          builder: (context, futureSnapshot) {
                                            if (futureSnapshot.hasError) {
                                              return Text("Error fetching conversion rates");
                                            }
                                            if (!futureSnapshot.hasData || futureSnapshot.data == null) {
                                              return Text(
                                                '0',
                                                style: TextStyle(
                                                  color: greyMinusTwo,
                                                  fontSize: small
                                                )
                                              );
                                            }

                                            var rates = futureSnapshot.data!['rates'];
                                            currencyController.setCurrencies(uniqueCurrenciesList);
                                            double total = 0;

                                            for (var doc in snapshot.data!.docs) {
                                              String currency = doc['Currency'] ?? '';
                                              double amount = doc['Target_Amount']?.toDouble() ?? 0.0;

                                              if(currency == mainCurrency) {
                                                total += amount;
                                              } else {
                                                total += (amount * rates[currency]);
                                              }
                                            }

                                            return StreamBuilder<QuerySnapshot>(
                                              stream: FirebaseFirestore.instance.collection('Savings').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasError) {
                                                  return Text("Error");
                                                }
                                                if (!snapshot.hasData || snapshot.data == null) {
                                                  return Text(
                                                    '0',
                                                    style: TextStyle(
                                                      color: greyMinusTwo,
                                                      fontSize: small
                                                    )
                                                  );
                                                }

                                                var docs = snapshot.data!.docs;
                                                String mainCurrency = userController.user?.mainCurrency ?? '';
                                                Set<String> uniqueCurrencies = {};

                                                for (var doc in docs) {
                                                  String currency = doc['Currency'];

                                                  if(currency != mainCurrency) {
                                                    uniqueCurrencies.add(currency);
                                                  }
                                                }
                                                List<String> uniqueCurrenciesList = uniqueCurrencies.toList();

                                                Future<Map<String, dynamic>> conversionRates = currencyService.conversionRate(mainCurrency, uniqueCurrenciesList, 'now');

                                                return FutureBuilder<Map<String, dynamic>>(
                                                  future: conversionRates,
                                                  builder: (context, futureSnapshot) {
                                                    if (futureSnapshot.hasError) {
                                                      return Text("Error fetching conversion rates");
                                                    }
                                                    if (!futureSnapshot.hasData || futureSnapshot.data == null) {
                                                      return Text(
                                                        '0',
                                                        style: TextStyle(
                                                          color: greyMinusTwo,
                                                          fontSize: small
                                                        )
                                                      );
                                                    }

                                                    var rates = futureSnapshot.data!['rates'];
                                                    double saved = 0;

                                                    for (var doc in docs) {
                                                      String currency = doc['Currency'];

                                                      if(currency != mainCurrency) {
                                                        uniqueCurrencies.add(currency);
                                                      }

                                                      if(doc['Records'] != null) {
                                                        for (var record in doc['Records']) {
                                                          if(record['Is_Deleted'] == false) {
                                                            double amount = record['Amount']?.toDouble() ?? 0.0;

                                                            if(currency == mainCurrency) {
                                                              if(record['Type_Id'] == 0) saved -= amount;
                                                              if(record['Type_Id'] == 1) saved += amount;
                                                            } else {
                                                              if(record['Type_Id'] == 0) saved -= (amount * rates[currency]);
                                                              if(record['Type_Id'] == 1) saved += (amount * rates[currency]);
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }

                                                    return Text(
                                                      NumberFormat('#,##0.###', 'de_DE').format(total - saved),
                                                      style: TextStyle(
                                                        color: greyMinusTwo,
                                                        fontSize: small
                                                      )
                                                    );
                                                  }
                                                );
                                              },
                                            );
                                          }
                                        );
                                      },
                                    )
                                  ],
                                )
                              ],
                            )
                          ]
                        ),
                      ),

                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('Savings').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text("Error");
                          }
                          if (!snapshot.hasData || snapshot.data == null) {
                            return ClipRRect(
                              borderRadius: borderRadius,
                              child: LinearProgressIndicator(
                                value: 1 / 1,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(mainBlue),
                              ),
                            );
                          }

                          String mainCurrency = userController.user?.mainCurrency ?? '';

                          Set<String> uniqueCurrencies = {};
                          for (var doc in snapshot.data!.docs) {
                            String currency = doc['Currency'];
                            if(currency != mainCurrency) {
                              uniqueCurrencies.add(currency);
                            }
                          }
                          List<String> uniqueCurrenciesList = uniqueCurrencies.toList();

                          Future<Map<String, dynamic>> conversionRates = currencyService.conversionRate(mainCurrency, uniqueCurrenciesList, 'now');

                          return FutureBuilder<Map<String, dynamic>>(
                            future: conversionRates,
                            builder: (context, futureSnapshot) {
                              if (futureSnapshot.hasError) {
                                return Text("Error fetching conversion rates");
                              }
                              if (!futureSnapshot.hasData || futureSnapshot.data == null) {
                                return ClipRRect(
                                  borderRadius: borderRadius,
                                  child: LinearProgressIndicator(
                                    value: 1 / 1,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(mainBlue),
                                  ),
                                );
                              }

                              var rates = futureSnapshot.data!['rates'];
                              currencyController.setCurrencies(uniqueCurrenciesList);
                              double total = 0;

                              for (var doc in snapshot.data!.docs) {
                                String currency = doc['Currency'] ?? '';
                                double amount = doc['Target_Amount']?.toDouble() ?? 0.0;

                                if(currency == mainCurrency) {
                                  total += amount;
                                } else {
                                  total += (amount * rates[currency]);
                                }
                              }

                              return StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance.collection('Savings').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Text("Error");
                                  }
                                  if (!snapshot.hasData || snapshot.data == null) {
                                    return ClipRRect(
                                      borderRadius: borderRadius,
                                      child: LinearProgressIndicator(
                                        value: 1 / 1,
                                        backgroundColor: Colors.grey[300],
                                        valueColor: AlwaysStoppedAnimation<Color>(mainBlue),
                                      ),
                                    );
                                  }

                                  var docs = snapshot.data!.docs;
                                  String mainCurrency = userController.user?.mainCurrency ?? '';
                                  Set<String> uniqueCurrencies = {};

                                  for (var doc in docs) {
                                    String currency = doc['Currency'];

                                    if(currency != mainCurrency) {
                                      uniqueCurrencies.add(currency);
                                    }
                                  }
                                  List<String> uniqueCurrenciesList = uniqueCurrencies.toList();

                                  Future<Map<String, dynamic>> conversionRates = currencyService.conversionRate(mainCurrency, uniqueCurrenciesList, 'now');

                                  return FutureBuilder<Map<String, dynamic>>(
                                    future: conversionRates,
                                    builder: (context, futureSnapshot) {
                                      if (futureSnapshot.hasError) {
                                        return Text("Error fetching conversion rates");
                                      }
                                      if (!futureSnapshot.hasData || futureSnapshot.data == null) {
                                        return ClipRRect(
                                          borderRadius: borderRadius,
                                          child: LinearProgressIndicator(
                                            value: 1 / 1,
                                            backgroundColor: Colors.grey[300],
                                            valueColor: AlwaysStoppedAnimation<Color>(mainBlue),
                                          ),
                                        );
                                      }

                                      var rates = futureSnapshot.data!['rates'];
                                      double saved = 0;

                                      for (var doc in docs) {
                                        String currency = doc['Currency'];

                                        if(currency != mainCurrency) {
                                          uniqueCurrencies.add(currency);
                                        }

                                        if(doc['Records'] != null) {
                                          for (var record in doc['Records']) {
                                            if(record['Is_Deleted'] == false) {
                                              double amount = record['Amount']?.toDouble() ?? 0.0;

                                              if(currency == mainCurrency) {
                                                if(record['Type_Id'] == 0) saved -= amount;
                                                if(record['Type_Id'] == 1) saved += amount;
                                              } else {
                                                if(record['Type_Id'] == 0) saved -= (amount * rates[currency]);
                                                if(record['Type_Id'] == 1) saved += (amount * rates[currency]);
                                              }
                                            }
                                          }
                                        }
                                      }

                                      return ClipRRect(
                                        borderRadius: borderRadius,
                                        child: LinearProgressIndicator(
                                          value: saved / total,
                                          backgroundColor: Colors.grey[300],
                                          valueColor: AlwaysStoppedAnimation<Color>(mainBlue),
                                        ),
                                      );
                                    }
                                  );
                                },
                              );
                            }
                          );
                        },
                      )
                    ]
                  )
                ),

                Obx(() {
                  return Column(
                    children: [
                      Subtab(tabs: tabs, type: 'all', disabled: false, controller: savingsTabController),
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
                        stream: FirebaseFirestore.instance.collection(allSubtabController.selectedTab.value == 0 ? 'Savings' : 'Savings').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).snapshots(),
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
                                'Belum ada${allSubtabController.selectedTab.value == 0 ? '' : ' catatan'} tabungan',
                                style: TextStyle(
                                  fontSize: tiny,
                                  color: greyMinusTwo
                                ),
                              )
                            );
                          }

                          savingController.setLength(snapshot.data!.docs.length);

                          var docs = snapshot.data!.docs;
                          List<Map<String, dynamic>> formattedDocs = snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                              data['Id'] = doc.id;
                              return data;
                          }).toList();
                          var check = null;
                          check = docs[0];
                          var groupedItems;
                          String mainCurrency = userController.user?.mainCurrency ?? '';
                          List<Map<String, dynamic>> records = [];

                          for(var doc in formattedDocs) {
                            if(doc['Records'] != null) {
                              for (int j = 0; j < doc['Records'].length; j++) {
                                doc['Records'][j]['Category'] = doc['Category'];
                                doc['Records'][j]['Name'] = doc['Name'];
                                doc['Records'][j]['Currency'] = doc['Currency'];
                                doc['Records'][j]['Note'] = doc['Note'];
                                doc['Records'][j]['Due_Date'] = doc['Due_Date'];
                                doc['Records'][j]['Target_Amount'] = doc['Target_Amount'];
                                doc['Records'][j]['Id'] = doc['Id'];
                                doc['Records'][j]['Index'] = j;
                                records.add(doc['Records'][j]);
                              }
                            }
                          }

                          records.sort((a, b) {
                            DateTime dateA = (a['Date'] as Timestamp).toDate();
                            DateTime dateB = (b['Date'] as Timestamp).toDate();
                            return dateB.compareTo(dateA);
                          });

                          if(allSubtabController.selectedTab.value == 1) {
                            groupedItems = groupBy(records, (record) {
                              DateTime dateTime = record['Date'].toDate().toUtc().add(Duration(hours: 7));
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

                          return allSubtabController.selectedTab.value == 0 ? ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              var doc = null;
                              doc = snapshot.data!.docs[index];

                              // Future<Map<String, dynamic>> conversionRates = currencyService.conversionRate(mainCurrency, currencyController.usedCurrencies ?? [], allSubtabController.selectedTab.value == 1 && doc.data()!.containsKey('Date') ? DateFormat('yyyy-MM-dd').format(DateFormat('d MMMM yyyy', 'id_ID').parse(groupedItems.keys.elementAt(index))) : 'now');
                              Future<Map<String, dynamic>> conversionRates = currencyService.conversionRate(mainCurrency, currencyController.usedCurrencies ?? [], 'now');

                              return Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      var filteredDocs = snapshot.data!.docs.toList();
                                      var doc = filteredDocs[index];
                                
                                      return InkWell(
                                        onTap: () {
                                          savingController.setSaving(
                                            SavingModel(
                                              id: doc.id,
                                              targetAmount: doc['Target_Amount'].toDouble(),
                                              currency: doc['Currency'],
                                              category: Category(id: doc['Category']['Id'], subId: doc['Category']['Sub_Id']),
                                              name: doc['Name'],
                                              note: doc['Note'],
                                              dueDate: doc['Due_Date'],
                                              records: List<Record>.from(
                                                (doc['Records'] as List<dynamic>).map((item) => Record(
                                                  amount: item['Amount'].toDouble(),
                                                  accountId: item['Account_Id'],
                                                  typeId: item['Type_Id'],
                                                  date: item['Date']
                                                )),
                                              ),
                                              isDeleted: false
                                            )
                                          );
                                          context.push('/manage/savings/saving/${doc.id}?action=view');
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
                                                      color: Color(int.parse('FF${doc['Category'] != null ? doc['Category']['Sub_Id'] != null ? categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).color : categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).color : '0f667b'}', radix: 16))
                                                    ),
                                                    child: Icon(
                                                      doc['Category'] != null ? icons[doc['Category']['Sub_Id'] != null ? categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).subs![doc['Category']['Sub_Id']].icon : categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).icon] : Icons.loop_rounded,
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
                                
                                                                    savingController.setSaving(
                                                                      SavingModel(
                                                                        id: doc.id,
                                                                        targetAmount: doc['Target_Amount'].toDouble(),
                                                                        currency: doc['Currency'],
                                                                        category: Category(id: doc['Category']['Id'], subId: doc['Category']['Sub_Id']),
                                                                        name: doc['Name'],
                                                                        note: doc['Note'],
                                                                        dueDate: doc['Due_Date'],
                                                                        records: List<Record>.from(
                                                                          (doc['Records'] as List<dynamic>).map((item) => Record(
                                                                            amount: item['Amount'].toDouble(),
                                                                            accountId: item['Account_Id'],
                                                                            typeId: item['Type_Id'],
                                                                            date: item['Date']
                                                                          )),
                                                                        ),
                                                                        isDeleted: false
                                                                      )
                                                                    );
                                
                                                                    context.push('/manage/savings/saving/${doc.id}?action=edit&from=dots');
                                                                  },
                                                                ),
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
                                                doc['Name'],
                                                style: TextStyle(
                                                  fontSize: semiMedium,
                                                  fontWeight: FontWeight.w500,
                                                  color: greyMinusTwo
                                                )
                                              ),
                                              Text(
                                                DateFormat('d MMMM yyyy', 'id_ID').format(doc['Due_Date'].toDate()),
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
                                                    Row(
                                                      children: [
                                                        Text(
                                                          userController.user?.mainCurrency == '' ? '' : currencies.firstWhere((currency) => currency["ISO_Code"] == userController.user?.mainCurrency)['Symbol'] ?? '',
                                                          style: TextStyle(
                                                            color: greyMinusTwo,
                                                            fontSize: small
                                                          ),
                                                        ),
                                                        StreamBuilder<QuerySnapshot>(
                                                          stream: FirebaseFirestore.instance.collection('Savings').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).snapshots(),
                                                          builder: (context, snapshot) {
                                                            if (snapshot.hasError) {
                                                              return Text("Error");
                                                            }
                                                            if (!snapshot.hasData || snapshot.data == null) {
                                                              return Text(
                                                                '0',
                                                                style: TextStyle(
                                                                  color: greyMinusTwo,
                                                                  fontSize: small
                                                                )
                                                              );
                                                            }

                                                            var docs = snapshot.data!.docs;
                                                            String mainCurrency = userController.user?.mainCurrency ?? '';
                                                            Set<String> uniqueCurrencies = {};

                                                            for (var doc in docs) {
                                                              String currency = doc['Currency'];

                                                              if(currency != mainCurrency) {
                                                                uniqueCurrencies.add(currency);
                                                              }
                                                            }
                                                            List<String> uniqueCurrenciesList = uniqueCurrencies.toList();

                                                            Future<Map<String, dynamic>> conversionRates = currencyService.conversionRate(mainCurrency, uniqueCurrenciesList, 'now');

                                                            return FutureBuilder<Map<String, dynamic>>(
                                                              future: conversionRates,
                                                              builder: (context, futureSnapshot) {
                                                                if (futureSnapshot.hasError) {
                                                                  return Text("Error fetching conversion rates");
                                                                }
                                                                if (!futureSnapshot.hasData || futureSnapshot.data == null) {
                                                                  return Text(
                                                                    '0',
                                                                    style: TextStyle(
                                                                      color: greyMinusTwo,
                                                                      fontSize: small
                                                                    )
                                                                  );
                                                                }

                                                                var rates = futureSnapshot.data!['rates'];
                                                                double total = 0;

                                                                if(doc['Records'] != null) {
                                                                  for (var data in docs) {
                                                                    String currency = data['Currency'];

                                                                    if(currency != mainCurrency) {
                                                                      uniqueCurrencies.add(currency);
                                                                    }

                                                                    if(doc.id == data.id) {
                                                                      for (var record in data['Records']) {
                                                                        if(record['Is_Deleted'] == false) {
                                                                          double amount = record['Amount']?.toDouble() ?? 0.0;

                                                                          if(currency == mainCurrency) {
                                                                            if(record['Type_Id'] == 0) total -= amount;
                                                                            if(record['Type_Id'] == 1) total += amount;
                                                                          } else {
                                                                            if(record['Type_Id'] == 0) total -= (amount * rates[currency]);
                                                                            if(record['Type_Id'] == 1) total += (amount * rates[currency]);
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }

                                                                return Text(
                                                                  NumberFormat('#,##0.###', 'de_DE').format(total),
                                                                  style: TextStyle(
                                                                    color: greyMinusTwo,
                                                                    fontSize: small
                                                                  )
                                                                );
                                                              }
                                                            );
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          userController.user?.mainCurrency == '' ? '' : currencies.firstWhere((currency) => currency["ISO_Code"] == userController.user?.mainCurrency)['Symbol'] ?? '',
                                                          style: TextStyle(
                                                            color: greyMinusTwo,
                                                            fontSize: small
                                                          ),
                                                        ),
                                                        StreamBuilder<QuerySnapshot>(
                                                          stream: FirebaseFirestore.instance.collection('Savings').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).snapshots(),
                                                          builder: (context, snapshot) {
                                                            if (snapshot.hasError) {
                                                              return Text("Error");
                                                            }
                                                            if (!snapshot.hasData || snapshot.data == null) {
                                                              return Text(
                                                                '0',
                                                                style: TextStyle(
                                                                  color: greyMinusTwo,
                                                                  fontSize: small
                                                                )
                                                              );
                                                            }

                                                            var docs = snapshot.data!.docs;
                                                            String mainCurrency = userController.user?.mainCurrency ?? '';
                                                            Set<String> uniqueCurrencies = {};

                                                            for (var doc in docs) {
                                                              String currency = doc['Currency'];

                                                              if(currency != mainCurrency) {
                                                                uniqueCurrencies.add(currency);
                                                              }
                                                            }
                                                            List<String> uniqueCurrenciesList = uniqueCurrencies.toList();

                                                            Future<Map<String, dynamic>> conversionRates = currencyService.conversionRate(mainCurrency, uniqueCurrenciesList, 'now');

                                                            return FutureBuilder<Map<String, dynamic>>(
                                                              future: conversionRates,
                                                              builder: (context, futureSnapshot) {
                                                                if (futureSnapshot.hasError) {
                                                                  return Text("Error fetching conversion rates");
                                                                }
                                                                if (!futureSnapshot.hasData || futureSnapshot.data == null) {
                                                                  return Text(
                                                                    '0',
                                                                    style: TextStyle(
                                                                      color: greyMinusTwo,
                                                                      fontSize: small
                                                                    )
                                                                  );
                                                                }

                                                                var rates = futureSnapshot.data!['rates'];
                                                                double total = 0;

                                                                if(doc['Records'] != null) {
                                                                  for (var data in docs) {
                                                                    String currency = data['Currency'];

                                                                    if(currency != mainCurrency) {
                                                                      uniqueCurrencies.add(currency);
                                                                    }

                                                                    if(doc.id == data.id) {
                                                                      for (var record in data['Records']) {
                                                                        if(record['Is_Deleted'] == false) {
                                                                          double amount = record['Amount']?.toDouble() ?? 0.0;

                                                                          if(currency == mainCurrency) {
                                                                            if(record['Type_Id'] == 0) total -= amount;
                                                                            if(record['Type_Id'] == 1) total += amount;
                                                                          } else {
                                                                            if(record['Type_Id'] == 0) total -= (amount * rates[currency]);
                                                                            if(record['Type_Id'] == 1) total += (amount * rates[currency]);
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }

                                                                return Text(
                                                                  NumberFormat('#,##0.###', 'de_DE').format(doc['Target_Amount'] - total),
                                                                  style: TextStyle(
                                                                    color: greyMinusTwo,
                                                                    fontSize: small
                                                                  )
                                                                );
                                                              }
                                                            );
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore.instance.collection('Savings').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).snapshots(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasError) {
                                                    return Text("Error");
                                                  }
                                                  if (!snapshot.hasData || snapshot.data == null) {
                                                    return ClipRRect(
                                                      borderRadius: borderRadius,
                                                      child: LinearProgressIndicator(
                                                        value: 1,
                                                        backgroundColor: Colors.grey[300],
                                                        valueColor: AlwaysStoppedAnimation<Color>(Color(int.parse('FF${doc['Category'] != null ? doc['Category']['Sub_Id'] != null ? categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).color : categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).color : '0f667b'}', radix: 16))),
                                                      ),
                                                    );
                                                  }

                                                  var docs = snapshot.data!.docs;
                                                  String mainCurrency = userController.user?.mainCurrency ?? '';
                                                  Set<String> uniqueCurrencies = {};

                                                  for (var doc in docs) {
                                                    String currency = doc['Currency'];

                                                    if(currency != mainCurrency) {
                                                      uniqueCurrencies.add(currency);
                                                    }
                                                  }
                                                  List<String> uniqueCurrenciesList = uniqueCurrencies.toList();

                                                  Future<Map<String, dynamic>> conversionRates = currencyService.conversionRate(mainCurrency, uniqueCurrenciesList, 'now');

                                                  return FutureBuilder<Map<String, dynamic>>(
                                                    future: conversionRates,
                                                    builder: (context, futureSnapshot) {
                                                      if (futureSnapshot.hasError) {
                                                        return Text("Error fetching conversion rates");
                                                      }
                                                      if (!futureSnapshot.hasData || futureSnapshot.data == null) {
                                                        return ClipRRect(
                                                          borderRadius: borderRadius,
                                                          child: LinearProgressIndicator(
                                                            value: 1,
                                                            backgroundColor: Colors.grey[300],
                                                            valueColor: AlwaysStoppedAnimation<Color>(Color(int.parse('FF${doc['Category'] != null ? doc['Category']['Sub_Id'] != null ? categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).color : categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).color : '0f667b'}', radix: 16))),
                                                          ),
                                                        );
                                                      }

                                                      var rates = futureSnapshot.data!['rates'];
                                                      double total = 0;

                                                      if(doc['Records'] != null) {
                                                        for (var data in docs) {
                                                          String currency = data['Currency'];

                                                          if(currency != mainCurrency) {
                                                            uniqueCurrencies.add(currency);
                                                          }

                                                          if(doc.id == data.id) {
                                                            for (var record in data['Records']) {
                                                              if(record['Is_Deleted'] == false) {
                                                                double amount = record['Amount']?.toDouble() ?? 0.0;

                                                                if(currency == mainCurrency) {
                                                                  if(record['Type_Id'] == 0) total -= amount;
                                                                  if(record['Type_Id'] == 1) total += amount;
                                                                } else {
                                                                  if(record['Type_Id'] == 0) total -= (amount * rates[currency]);
                                                                  if(record['Type_Id'] == 1) total += (amount * rates[currency]);
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }

                                                      return ClipRRect(
                                                        borderRadius: borderRadius,
                                                        child: LinearProgressIndicator(
                                                          value: doc['Target_Amount'] == null ? 1 : total / doc['Target_Amount'],
                                                          backgroundColor: Colors.grey[300],
                                                          valueColor: AlwaysStoppedAnimation<Color>(Color(int.parse('FF${doc['Category'] != null ? doc['Category']['Sub_Id'] != null ? categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).color : categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).color : '0f667b'}', radix: 16))),
                                                        ),
                                                      );
                                                    }
                                                  );
                                                },
                                              )
                                            ]
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ]
                              );
                            }
                          ) : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: groupedItems.length,
                            itemBuilder: (context, index) {
                              var doc = null;
                              doc = groupedItems[index];

                              Future<Map<String, dynamic>> conversionRates = currencyService.conversionRate(mainCurrency, currencyController.usedCurrencies ?? [], DateFormat('yyyy-MM-dd').format(DateFormat('d MMMM yyyy', 'id_ID').parse(groupedItems.keys.elementAt(index))));
                              
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
                              
                                  for (var savingDoc in groupedItems[groupedItems.keys.elementAt(index)]) {
                                    String currency = accountController.accounts.firstWhere((account) => account.id == savingDoc['Account_Id']).currency;
                                    int type = savingDoc['Type_Id'];
                                    double amount = type == 3 ? savingDoc['Fee']?.toDouble() ?? 0.0 : savingDoc['Amount']?.toDouble() ?? 0.0;
                                    
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
                                  var absTotal = total.abs();

                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                    margin: EdgeInsets.only(bottom: (index + 1 != (groupedItems.length)) ? 10 : 0),
                                    decoration: BoxDecoration(
                                      color: greyMinusFive,
                                      borderRadius: borderRadius,
                                    ),
                                    child: Column(
                                      children: [
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
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: groupedItems[groupedItems.keys.elementAt(index)].length,
                                          itemBuilder: (context, subIndex) {
                                            return InkWell(
                                              onTap: () async {
                                                savingController.setRecord(
                                                  Record(
                                                    amount: groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Amount'].toDouble(),
                                                    accountId: groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Account_Id'],
                                                    typeId: groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Type_Id'],
                                                    date: groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Date']
                                                  )
                                                );
                                                context.push('/manage/savings/saving/record/${groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Id']}/$subIndex?action=view');
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
                                                              groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Name'],
                                                              style: TextStyle(
                                                                fontSize: small
                                                              )
                                                            ),
                                                        
                                                            Text(
                                                              accountController.accounts.value.firstWhere((account) => account.id == groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Account_Id']).name,
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
                                                          currencies.firstWhere((currency) => currency['ISO_Code'] == accountController.accounts.value.firstWhere((account) => account.id == groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Account_Id']).currency)['Symbol'] ?? '',
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
                                      ],
                                    )
                                  );
                                }
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
    });
  }
}