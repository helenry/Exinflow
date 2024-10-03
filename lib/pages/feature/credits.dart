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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        creditsTabController.animateTo(index);
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
    DateTime now = DateTime.now().toUtc().add(Duration(hours: 7));
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);

    return Obx(() {
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
                            stream: FirebaseFirestore.instance.collection('Credits').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).snapshots(),
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
                                    double amount = doc['Limit_Amount']?.toDouble() ?? 0.0;

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
                                  'Terpakai',
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
                                        fontSize: verySmall
                                      ),
                                    ),
                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance.collection('Transactions').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).where('Type_Id', isEqualTo: 0).where('Date', isGreaterThanOrEqualTo: startOfMonth).where('Date', isLessThanOrEqualTo: endOfMonth).snapshots(),
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
                                          if(creditController.credits.any((credit) => credit.id == doc['Account_Id']['Source'])) {
                                            String currencySource;
                                            if(!(doc['Type_Id'] == 2 && doc['Fee'] == null)) {
                                              if(doc['Type_Id'] == 0 || doc['Type_Id'] == 2) {
                                                currencySource = doc['Account_Id']['Source'];
                                              } else {
                                                currencySource = doc['Account_Id']['Destination'];
                                              }

                                              String currency = '';
                                              try {
                                                currency = accountController.accounts.firstWhere((account) => account.id == currencySource)?.currency ?? '';
                                              } catch (e) {
                                                try {
                                                  currency = creditController.credits.firstWhere((credit) => credit.id == currencySource)?.currency ?? '';
                                                } catch (e) {
                                                  print('Error: $e');
                                                }
                                              }

                                              if(currency != mainCurrency) {
                                                uniqueCurrencies.add(currency);
                                              }
                                            }
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

                                            for (var doc in snapshot.data!.docs) {
                                              if(creditController.credits.any((credit) => credit.id == doc['Account_Id']['Source'])) {
                                                String currencySource;
                                                if(!(doc['Type_Id'] == 2 && doc['Fee'] == null)) {
                                                  if(doc['Type_Id'] == 0 || doc['Type_Id'] == 2) {
                                                    currencySource = doc['Account_Id']['Source'];
                                                  } else {
                                                    currencySource = doc['Account_Id']['Destination'];
                                                  }

                                                  String currency = '';
                                                  try {
                                                    currency = accountController.accounts.firstWhere((account) => account.id == currencySource)?.currency ?? '';
                                                  } catch (e) {
                                                    try {
                                                      currency = creditController.credits.firstWhere((credit) => credit.id == currencySource)?.currency ?? '';
                                                    } catch (e) {
                                                      print('Error: $e');
                                                    }
                                                  }

                                                  if(currency != mainCurrency) {
                                                    uniqueCurrencies.add(currency);
                                                  }

                                                  double amount = doc['Type_Id'] == 2 ? doc['Fee']?.toDouble() ?? 0.0 : doc['Amount']?.toDouble() ?? 0.0;

                                                  if(currency == mainCurrency) {
                                                    total += amount;
                                                  } else {
                                                    total += (amount * rates[currency]);
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
                                      stream: FirebaseFirestore.instance.collection('Credits').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).snapshots(),
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
                                              double amount = doc['Limit_Amount']?.toDouble() ?? 0.0;

                                              if(currency == mainCurrency) {
                                                total += amount;
                                              } else {
                                                total += (amount * rates[currency]);
                                              }
                                            }

                                            return StreamBuilder<QuerySnapshot>(
                                              stream: FirebaseFirestore.instance.collection('Transactions').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).where('Type_Id', isEqualTo: 0).where('Date', isGreaterThanOrEqualTo: startOfMonth).where('Date', isLessThanOrEqualTo: endOfMonth).snapshots(),
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
                                                  if(creditController.credits.any((credit) => credit.id == doc['Account_Id']['Source'])) {
                                                    String currencySource;
                                                    if(!(doc['Type_Id'] == 2 && doc['Fee'] == null)) {
                                                      if(doc['Type_Id'] == 0 || doc['Type_Id'] == 2) {
                                                        currencySource = doc['Account_Id']['Source'];
                                                      } else {
                                                        currencySource = doc['Account_Id']['Destination'];
                                                      }

                                                      String currency = '';
                                                      try {
                                                        currency = accountController.accounts.firstWhere((account) => account.id == currencySource)?.currency ?? '';
                                                      } catch (e) {
                                                        try {
                                                          currency = creditController.credits.firstWhere((credit) => credit.id == currencySource)?.currency ?? '';
                                                        } catch (e) {
                                                          print('Error: $e');
                                                        }
                                                      }

                                                      if(currency != mainCurrency) {
                                                        uniqueCurrencies.add(currency);
                                                      }
                                                    }
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
                                                    double used = 0;

                                                    for (var doc in snapshot.data!.docs) {
                                                      if(creditController.credits.any((credit) => credit.id == doc['Account_Id']['Source'])) {
                                                        String currencySource;
                                                        if(!(doc['Type_Id'] == 2 && doc['Fee'] == null)) {
                                                          if(doc['Type_Id'] == 0 || doc['Type_Id'] == 2) {
                                                            currencySource = doc['Account_Id']['Source'];
                                                          } else {
                                                            currencySource = doc['Account_Id']['Destination'];
                                                          }

                                                          String currency = '';
                                                          try {
                                                            currency = accountController.accounts.firstWhere((account) => account.id == currencySource)?.currency ?? '';
                                                          } catch (e) {
                                                            try {
                                                              currency = creditController.credits.firstWhere((credit) => credit.id == currencySource)?.currency ?? '';
                                                            } catch (e) {
                                                              print('Error: $e');
                                                            }
                                                          }

                                                          if(currency != mainCurrency) {
                                                            uniqueCurrencies.add(currency);
                                                          }

                                                          double amount = doc['Type_Id'] == 2 ? doc['Fee']?.toDouble() ?? 0.0 : doc['Amount']?.toDouble() ?? 0.0;

                                                          if(currency == mainCurrency) {
                                                            used += amount;
                                                          } else {
                                                            used += (amount * rates[currency]);
                                                          }
                                                        }
                                                      }
                                                    }

                                                    return Text(
                                                      NumberFormat('#,##0.###', 'de_DE').format(total - used),
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
                                ),
                              ],
                            )
                          ]
                        ),
                      ),

                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('Credits').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).snapshots(),
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

                          if (snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text(
                                'Belum ada kredit',
                                style: TextStyle(
                                  fontSize: tiny,
                                  color: greyMinusTwo
                                ),
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
                                double amount = doc['Limit_Amount']?.toDouble() ?? 0.0;

                                if(currency == mainCurrency) {
                                  total += amount;
                                } else {
                                  total += (amount * rates[currency]);
                                }
                              }

                              return StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance.collection('Transactions').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).where('Type_Id', isEqualTo: 0).where('Date', isGreaterThanOrEqualTo: startOfMonth).where('Date', isLessThanOrEqualTo: endOfMonth).snapshots(),
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
                                    if(creditController.credits.any((credit) => credit.id == doc['Account_Id']['Source'])) {
                                      String currencySource;
                                      if(!(doc['Type_Id'] == 2 && doc['Fee'] == null)) {
                                        if(doc['Type_Id'] == 0 || doc['Type_Id'] == 2) {
                                          currencySource = doc['Account_Id']['Source'];
                                        } else {
                                          currencySource = doc['Account_Id']['Destination'];
                                        }

                                        String currency = '';
                                        try {
                                          currency = accountController.accounts.firstWhere((account) => account.id == currencySource)?.currency ?? '';
                                        } catch (e) {
                                          try {
                                            currency = creditController.credits.firstWhere((credit) => credit.id == currencySource)?.currency ?? '';
                                          } catch (e) {
                                            print('Error: $e');
                                          }
                                        }

                                        if(currency != mainCurrency) {
                                          uniqueCurrencies.add(currency);
                                        }
                                      }
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
                                      double used = 0;

                                      for (var doc in snapshot.data!.docs) {
                                        if(creditController.credits.any((credit) => credit.id == doc['Account_Id']['Source'])) {
                                          String currencySource;
                                          if(!(doc['Type_Id'] == 2 && doc['Fee'] == null)) {
                                            if(doc['Type_Id'] == 0 || doc['Type_Id'] == 2) {
                                              currencySource = doc['Account_Id']['Source'];
                                            } else {
                                              currencySource = doc['Account_Id']['Destination'];
                                            }

                                            String currency = '';
                                            try {
                                              currency = accountController.accounts.firstWhere((account) => account.id == currencySource)?.currency ?? '';
                                            } catch (e) {
                                              try {
                                                currency = creditController.credits.firstWhere((credit) => credit.id == currencySource)?.currency ?? '';
                                              } catch (e) {
                                                print('Error: $e');
                                              }
                                            }

                                            if(currency != mainCurrency) {
                                              uniqueCurrencies.add(currency);
                                            }

                                            double amount = doc['Type_Id'] == 2 ? doc['Fee']?.toDouble() ?? 0.0 : doc['Amount']?.toDouble() ?? 0.0;

                                            if(currency == mainCurrency) {
                                              used += amount;
                                            } else {
                                              used += (amount * rates[currency]);
                                            }
                                          }
                                        }
                                      }

                                      return ClipRRect(
                                        borderRadius: borderRadius,
                                        child: LinearProgressIndicator(
                                          value: used / total,
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
                            itemCount: allSubtabController.selectedTab.value == 1 && check.data()!.containsKey('Date') ? groupedItems.length : 1,
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
                                                limits: null,
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
                                                                          limits: null,
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
                                                                              limits: null,
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
                                                            stream: FirebaseFirestore.instance.collection('Transactions').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).where('Type_Id', isEqualTo: 0).where('Date', isGreaterThanOrEqualTo: startOfMonth).where('Date', isLessThanOrEqualTo: endOfMonth).snapshots(),
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

                                                              for (var transDoc in snapshot.data!.docs) {
                                                                if(transDoc['Account_Id']['Source'] == doc.id) {
                                                                  String currencySource;
                                                                  if(!(transDoc['Type_Id'] == 2 && transDoc['Fee'] == null)) {
                                                                    if(transDoc['Type_Id'] == 0 || transDoc['Type_Id'] == 2) {
                                                                      currencySource = transDoc['Account_Id']['Source'];
                                                                    } else {
                                                                      currencySource = transDoc['Account_Id']['Destination'];
                                                                    }

                                                                    String currency = '';
                                                                    try {
                                                                      currency = accountController.accounts.firstWhere((account) => account.id == currencySource)?.currency ?? '';
                                                                    } catch (e) {
                                                                      try {
                                                                        currency = creditController.credits.firstWhere((credit) => credit.id == currencySource)?.currency ?? '';
                                                                      } catch (e) {
                                                                        print('Error: $e');
                                                                      }
                                                                    }

                                                                    if(currency != mainCurrency) {
                                                                      uniqueCurrencies.add(currency);
                                                                    }
                                                                  }
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


                                                                  for (var transDoc in snapshot.data!.docs) {
                                                                    if(transDoc['Account_Id']['Source'] == doc.id) {
                                                                      String currencySource;
                                                                      if(!(transDoc['Type_Id'] == 2 && transDoc['Fee'] == null)) {
                                                                        if(transDoc['Type_Id'] == 0 || transDoc['Type_Id'] == 2) {
                                                                          currencySource = transDoc['Account_Id']['Source'];
                                                                        } else {
                                                                          currencySource = transDoc['Account_Id']['Destination'];
                                                                        }

                                                                        String currency = '';
                                                                        try {
                                                                          currency = accountController.accounts.firstWhere((account) => account.id == currencySource)?.currency ?? '';
                                                                        } catch (e) {
                                                                          try {
                                                                            currency = creditController.credits.firstWhere((credit) => credit.id == currencySource)?.currency ?? '';
                                                                          } catch (e) {
                                                                            print('Error: $e');
                                                                          }
                                                                        }

                                                                        if(currency != mainCurrency) {
                                                                          uniqueCurrencies.add(currency);
                                                                        }

                                                                        double amount = transDoc['Type_Id'] == 2 ? transDoc['Fee']?.toDouble() ?? 0.0 : transDoc['Amount']?.toDouble() ?? 0.0;

                                                                        if(currency == mainCurrency) {
                                                                          total += amount;
                                                                        } else {
                                                                          total += (amount * rates[currency]);
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
                                                            stream: FirebaseFirestore.instance.collection('Transactions').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).where('Type_Id', isEqualTo: 0).where('Date', isGreaterThanOrEqualTo: startOfMonth).where('Date', isLessThanOrEqualTo: endOfMonth).snapshots(),
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

                                                              for (var transDoc in snapshot.data!.docs) {
                                                                if(transDoc['Account_Id']['Source'] == doc.id) {
                                                                  String currencySource;
                                                                  if(!(transDoc['Type_Id'] == 2 && transDoc['Fee'] == null)) {
                                                                    if(transDoc['Type_Id'] == 0 || transDoc['Type_Id'] == 2) {
                                                                      currencySource = transDoc['Account_Id']['Source'];
                                                                    } else {
                                                                      currencySource = transDoc['Account_Id']['Destination'];
                                                                    }

                                                                    String currency = '';
                                                                    try {
                                                                      currency = accountController.accounts.firstWhere((account) => account.id == currencySource)?.currency ?? '';
                                                                    } catch (e) {
                                                                      try {
                                                                        currency = creditController.credits.firstWhere((credit) => credit.id == currencySource)?.currency ?? '';
                                                                      } catch (e) {
                                                                        print('Error: $e');
                                                                      }
                                                                    }

                                                                    if(currency != mainCurrency) {
                                                                      uniqueCurrencies.add(currency);
                                                                    }
                                                                  }
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


                                                                  for (var transDoc in snapshot.data!.docs) {
                                                                    if(transDoc['Account_Id']['Source'] == doc.id) {
                                                                      String currencySource;
                                                                      if(!(transDoc['Type_Id'] == 2 && transDoc['Fee'] == null)) {
                                                                        if(transDoc['Type_Id'] == 0 || transDoc['Type_Id'] == 2) {
                                                                          currencySource = transDoc['Account_Id']['Source'];
                                                                        } else {
                                                                          currencySource = transDoc['Account_Id']['Destination'];
                                                                        }

                                                                        String currency = '';
                                                                        try {
                                                                          currency = accountController.accounts.firstWhere((account) => account.id == currencySource)?.currency ?? '';
                                                                        } catch (e) {
                                                                          try {
                                                                            currency = creditController.credits.firstWhere((credit) => credit.id == currencySource)?.currency ?? '';
                                                                          } catch (e) {
                                                                            print('Error: $e');
                                                                          }
                                                                        }

                                                                        if(currency != mainCurrency) {
                                                                          uniqueCurrencies.add(currency);
                                                                        }

                                                                        double amount = transDoc['Type_Id'] == 2 ? transDoc['Fee']?.toDouble() ?? 0.0 : transDoc['Amount']?.toDouble() ?? 0.0;

                                                                        if(currency == mainCurrency) {
                                                                          total += amount;
                                                                        } else {
                                                                          total += (amount * rates[currency]);
                                                                        }
                                                                      }
                                                                    }
                                                                  }

                                                                  return Text(
                                                                    NumberFormat('#,##0.###', 'de_DE').format(doc['Limit_Amount'] - total),
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
                                                  stream: FirebaseFirestore.instance.collection('Transactions').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).where('Type_Id', isEqualTo: 0).where('Date', isGreaterThanOrEqualTo: startOfMonth).where('Date', isLessThanOrEqualTo: endOfMonth).snapshots(),
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
                                                          valueColor: AlwaysStoppedAnimation<Color>(Color(int.parse('FF${doc['Color']}', radix: 16))),
                                                        ),
                                                      );
                                                    }

                                                    String mainCurrency = userController.user?.mainCurrency ?? '';
                                                    Set<String> uniqueCurrencies = {};

                                                    for (var transDoc in snapshot.data!.docs) {
                                                      if(transDoc['Account_Id']['Source'] == doc.id) {
                                                        String currencySource;
                                                        if(!(transDoc['Type_Id'] == 2 && transDoc['Fee'] == null)) {
                                                          if(transDoc['Type_Id'] == 0 || transDoc['Type_Id'] == 2) {
                                                            currencySource = transDoc['Account_Id']['Source'];
                                                          } else {
                                                            currencySource = transDoc['Account_Id']['Destination'];
                                                          }

                                                          String currency = '';
                                                          try {
                                                            currency = accountController.accounts.firstWhere((account) => account.id == currencySource)?.currency ?? '';
                                                          } catch (e) {
                                                            try {
                                                              currency = creditController.credits.firstWhere((credit) => credit.id == currencySource)?.currency ?? '';
                                                            } catch (e) {
                                                              print('Error: $e');
                                                            }
                                                          }

                                                          if(currency != mainCurrency) {
                                                            uniqueCurrencies.add(currency);
                                                          }
                                                        }
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
                                                              valueColor: AlwaysStoppedAnimation<Color>(Color(int.parse('FF${doc['Color']}', radix: 16))),
                                                            ),
                                                          );
                                                        }

                                                        var rates = futureSnapshot.data!['rates'];
                                                        double total = 0;


                                                        for (var transDoc in snapshot.data!.docs) {
                                                          if(transDoc['Account_Id']['Source'] == doc.id) {
                                                            String currencySource;
                                                            if(!(transDoc['Type_Id'] == 2 && transDoc['Fee'] == null)) {
                                                              if(transDoc['Type_Id'] == 0 || transDoc['Type_Id'] == 2) {
                                                                currencySource = transDoc['Account_Id']['Source'];
                                                              } else {
                                                                currencySource = transDoc['Account_Id']['Destination'];
                                                              }

                                                              String currency = '';
                                                              try {
                                                                currency = accountController.accounts.firstWhere((account) => account.id == currencySource)?.currency ?? '';
                                                              } catch (e) {
                                                                try {
                                                                  currency = creditController.credits.firstWhere((credit) => credit.id == currencySource)?.currency ?? '';
                                                                } catch (e) {
                                                                  print('Error: $e');
                                                                }
                                                              }

                                                              if(currency != mainCurrency) {
                                                                uniqueCurrencies.add(currency);
                                                              }

                                                              double amount = transDoc['Type_Id'] == 2 ? transDoc['Fee']?.toDouble() ?? 0.0 : transDoc['Amount']?.toDouble() ?? 0.0;

                                                              if(currency == mainCurrency) {
                                                                total += amount;
                                                              } else {
                                                                total += (amount * rates[currency]);
                                                              }
                                                            }
                                                          }
                                                        }

                                                        return ClipRRect(
                                                          borderRadius: borderRadius,
                                                          child: LinearProgressIndicator(
                                                            value: total / doc['Limit_Amount'],
                                                            backgroundColor: Colors.grey[300],
                                                            valueColor: AlwaysStoppedAnimation<Color>(Color(int.parse('FF${doc['Color']}', radix: 16))),
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

                                  if(allSubtabController.selectedTab.value == 1)
                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance.collection('Credits').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return Text("Error");
                                        }
                                        if (!snapshot.hasData || snapshot.data == null) {
                                          return Text(
                                            'Belum ada tagihan kredit',
                                            style: TextStyle(
                                              color: mainBlue,
                                              fontSize: semiLarge
                                            )
                                          );
                                        }

                                        if (snapshot.data!.docs.isEmpty) {
                                          return Center(
                                            child: Text(
                                              'Belum ada tagihan kredit',
                                              style: TextStyle(
                                                fontSize: tiny,
                                                color: greyMinusTwo
                                              ),
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
                                                'Belum ada tagihan kredit',
                                                style: TextStyle(
                                                  color: mainBlue,
                                                  fontSize: semiLarge
                                                )
                                              );
                                            }

                                            var rates = futureSnapshot.data!['rates'];
                                            currencyController.setCurrencies(uniqueCurrenciesList);
                                            double total = 0;

                                            Map<String, Map<String, double>> monthYears = {};
                                            for (var doc in snapshot.data!.docs) {
                                              String currency = doc['Currency'] ?? '';
                                              double limitAmount = doc['Limit_Amount']?.toDouble() ?? 0.0;

                                              if(doc['Limits'] != null) {
                                                for (var limit in doc['Limits']) {
                                                  // print("limit['Month_Year']");
                                                  // print(limit['Month_Year']);
                                                  // print("limit['Limit']");
                                                  // print(limit['Limit']);

                                                  String year = limit['Month_Year'].toDate().year.toString();
                                                  String monthName = DateFormat('MMMM', 'id_ID').format(limit['Month_Year'].toDate());

                                                  if (monthYears.containsKey(year)) {
                                                    if (monthYears[year]!.containsKey(monthName)) {
                                                      monthYears[year]![monthName] = monthYears[year]![monthName]! + (currency == mainCurrency ? limitAmount - limit['Limit'] : (limitAmount - limit['Limit']) * rates[currency]);
                                                    } else {
                                                      monthYears[year]![monthName] = currency == mainCurrency ? limitAmount - limit['Limit'] : (limitAmount - limit['Limit']) * rates[currency];
                                                    }
                                                  } else {
                                                    monthYears[year] = {
                                                      monthName: currency == mainCurrency ? limitAmount - limit['Limit'] : (limitAmount - limit['Limit']) * rates[currency],
                                                    };
                                                  }
                                                }
                                              }

                                              print("monthYears NOW");
                                              print(monthYears);
                                            }

                                            return ListView.builder(
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              itemCount: monthYears.length,
                                              itemBuilder: (context, index) {
                                                return Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                                  margin: EdgeInsets.only(bottom: (index + 1 != monthYears.length) ? 10 : 0),
                                                  decoration: BoxDecoration(
                                                    color: greyMinusFive,
                                                    borderRadius: borderRadius,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.only(bottom: 15),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              monthYears.keys.elementAt(index)
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  userController.user?.mainCurrency == '' ? '' : currencies.firstWhere((currency) => currency["ISO_Code"] == userController.user?.mainCurrency)['Symbol'] ?? '',
                                                                  style: TextStyle(
                                                                    color: greyMinusTwo,
                                                                    fontSize: tiny
                                                                  ),
                                                                ),
                                                                Text(
                                                                  NumberFormat('#,##0.###', 'de_DE').format(monthYears[monthYears.keys.elementAt(index)]!.values.fold(0, (num sum, double value) => sum + value)),
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
                                                        itemCount: monthYears[monthYears.keys.elementAt(index)]!.length,
                                                        itemBuilder: (context, subIndex) {
                                                          return Container(
                                                            margin: EdgeInsets.only(bottom: (subIndex + 1 != monthYears[monthYears.keys.elementAt(subIndex)]!.length) ? 10 : 0),
                                                            decoration: BoxDecoration(
                                                              color: greyMinusFive,
                                                              borderRadius: borderRadius,
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  monthYears[monthYears.keys.elementAt(index)]!.keys.elementAt(subIndex),
                                                                  style: TextStyle(
                                                                    color: greyMinusThree,
                                                                    fontSize: semiVerySmall
                                                                  ),
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      userController.user?.mainCurrency == '' ? '' : currencies.firstWhere((currency) => currency["ISO_Code"] == userController.user?.mainCurrency)['Symbol'] ?? '',
                                                                      style: TextStyle(
                                                                        color: greyMinusTwo,
                                                                        fontSize: semiVerySmall
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      NumberFormat('#,##0.###', 'de_DE').format(monthYears[monthYears.keys.elementAt(index)]![monthYears[monthYears.keys.elementAt(index)]!.keys.elementAt(subIndex)]),
                                                                      style: TextStyle(
                                                                        color: greyMinusTwo,
                                                                        fontSize: semiVerySmall
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              ]
                                                            )
                                                          );
                                                        }
                                                      )
                                                    ]
                                                  )
                                                );
                                              }
                                            );
                                          }
                                        );
                                      },
                                    )
                                  
                                  // Padding(
                                  //   padding: const EdgeInsets.only(bottom: 15),
                                  //   child: Row(
                                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //     children: [
                                  //       Row(
                                  //         children: [
                                  //           Column(
                                  //             crossAxisAlignment: CrossAxisAlignment.start,
                                  //             children: [
                                  //               Text(
                                  //                 'Skibidi',
                                  //                 style: TextStyle(
                                  //                   fontSize: small
                                  //                 )
                                  //               ),
                                            
                                  //               Row(
                                  //                 children: [
                                  //                   Text(
                                  //                     userController.user?.mainCurrency == '' ? '' : currencies.firstWhere((currency) => currency["ISO_Code"] == userController.user?.mainCurrency)['Symbol'] ?? '',
                                  //                     style: TextStyle(
                                  //                       fontSize: semiVerySmall,
                                  //                       fontWeight: FontWeight.w500,
                                  //                       color: greyMinusThree
                                  //                     )
                                  //                   ),
                                  //                   Text(
                                  //                     NumberFormat('#,##0.###', 'de_DE').format(groupedItems[groupedItems.keys.elementAt(index)][subIndex]['Amount']),
                                  //                     style: TextStyle(
                                  //                       fontSize: semiVerySmall,
                                  //                       fontWeight: FontWeight.w500,
                                  //                       color: greyMinusThree
                                  //                     )
                                  //                   ),
                                  //                 ],
                                  //               )
                                  //             ],
                                  //           ),
                                  //         ],
                                  //       ),
                                
                                  //       Container(
                                  //         width: 41,
                                  //         height: 41,
                                  //         decoration: BoxDecoration(
                                  //           border: Border.all(color: greyMinusTwo, width: 1),
                                  //           shape: BoxShape.circle,
                                  //         ),
                                  //         child: Center(
                                  //           child: IconButton(
                                  //             padding: EdgeInsets.all(5),
                                  //             icon: const Icon(
                                  //               Icons.arrow_forward_rounded,
                                  //               color: greyMinusTwo,
                                  //               size: 30
                                  //             ),
                                  //             onPressed: () {
                                  //               context.push('/manage/transactions');
                                  //             },
                                  //           ),
                                  //         ),
                                  //       )
                                  //     ],
                                  //   )
                                  // )
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
    });
  }
}