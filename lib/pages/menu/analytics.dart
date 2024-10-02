import 'package:exinflow/controllers/subtab.dart';
import 'package:exinflow/widgets/padding.dart';
import 'package:exinflow/constants/constants.dart';
import 'package:exinflow/constants/data.dart';
import 'package:flutter/material.dart';
import 'package:exinflow/widgets/subtab.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exinflow/controllers/user.dart';
import 'package:exinflow/controllers/currency.dart';
import 'package:exinflow/services/currency.dart';
import 'package:exinflow/controllers/account.dart';
import 'package:exinflow/controllers/credit.dart';

class ChartData {
  ChartData(this.x, this.y);
 
  final String x;
  double y;
}

class Analytics extends StatefulWidget {
  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  final user = FirebaseAuth.instance.currentUser;
  final AllSubtabController allSubtabController = Get.find<AllSubtabController>();
  late TabController analyticsTabController;
  final UserController userController = Get.find<UserController>();
  final CurrencyController currencyController = Get.find<CurrencyController>();
  final CurrencyService currencyService = CurrencyService();
  late StreamSubscription<int> selectedTabSubscription;
  List<String> filter = ['0', '0'];

  late List<ChartData> expenseWeeklyData;
  late List<ChartData> incomeWeeklyData;
  late List<ChartData> expenseMonthlyData;
  late List<ChartData> incomeMonthlyData;
  late TooltipBehavior _tooltip;

  final List<Map> tabs = [
    {
      "tab": "Statistik",
      "title": "Statistik Keuangan"
    },
    {
      "tab": "Wawasan",
      "title": "Wawasan Keuangan"
    },
  ];

  @override
  void initState() {
    super.initState();
    Get.delete<TabController>();
    analyticsTabController = Get.put(TabController(length: tabs.length, vsync: Scaffold.of(context)));

    selectedTabSubscription = allSubtabController.selectedTab.listen((index) {
      analyticsTabController.animateTo(index);
    });

    _tooltip = TooltipBehavior(enable: true);

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
    final AccountController accountController = Get.find<AccountController>();
    final CreditController creditController = Get.find<CreditController>();  

    DateTime now = DateTime.now().toUtc().add(Duration(hours: 7));
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = now.add(Duration(days: 7 - now.weekday));
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: AllPadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Text(
                    "Analitik",
                    style: TextStyle(
                      fontSize: large,
                      color: mainBluePlusOne,
                      fontFamily: "Open Sans",
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
          
                Subtab(tabs: tabs, type: 'all', disabled: false, controller: analyticsTabController),
          
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() {
                        return Text(
                          tabs[allSubtabController.selectedTab.value]['title'],
                          style: TextStyle(
                            fontSize: semiMedium,
                            color: greyMinusOne,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Open Sans"
                          ),
                        );
                      }),
                          
                      // Container(
                      //   width: 46,
                      //   height: 46,
                      //   decoration: BoxDecoration(
                      //     border: Border.all(color: greyMinusTwo, width: 1),
                      //     shape: BoxShape.circle,
                      //   ),
                      //   child: Center(
                      //     child: IconButton(
                      //       padding: EdgeInsets.all(5),
                      //       icon: const Icon(
                      //         Icons.download_outlined,
                      //         color: greyMinusTwo,
                      //         size: 30
                      //       ),
                      //       onPressed: () {
                              
                      //       },
                      //     ),
                      //   ),
                      // )
                    ]
                  ),
                ),
          
                Obx(() {
                  return allSubtabController.selectedTab.value == 0 ?
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          // Pengeluaran
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SizedBox(
                              width: double.infinity,
                              child: Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: mainBlueMinusFour,
                                  borderRadius: borderRadius
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        'Transaksi',
                                        style: TextStyle(
                                          fontSize: small,
                                          fontWeight: FontWeight.w500
                                        )
                                      ),
                                    ),
                              
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          // Time
                                          Padding(
                                            padding: const EdgeInsets.only(right: 7.5),
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                border: Border.all(color: mainBlue, width: 1),
                                                borderRadius: borderRadius,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 12.5),
                                                child: DropdownButtonHideUnderline(
                                                  child: SizedBox(
                                                    height: 35,
                                                    child: DropdownButton<String>(
                                                      value: filter[0],
                                                      items: [
                                                        DropdownMenuItem(
                                                          child: Text('Minggu Ini'),
                                                          value: '0',
                                                        ),
                                                        DropdownMenuItem(
                                                          child: Text('Bulan Ini'),
                                                          value: '1',
                                                        ),
                                                      ],
                                                      onChanged: (value) {
                                                        setState(() {
                                                          filter[0] = value ?? '';
                                                        });
                                                      },
                                                      style: TextStyle(color: mainBlue, fontSize: tiny),
                                                      iconEnabledColor: mainBlue,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance.collection('Transactions').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).where('Date', isGreaterThanOrEqualTo: filter[0] == '0' ? startOfWeek : startOfMonth).where('Date', isLessThanOrEqualTo: filter[0] == '0' ? endOfWeek : endOfMonth).snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return Text("Error");
                                        }
                                        if (!snapshot.hasData || snapshot.data == null) {
                                          List<ChartData> expenseData = [];
                                          List<ChartData> incomeData = [];

                                          if (filter[0] == '0') {
                                            List<String> weekDays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                                            for (var day in weekDays) {
                                              expenseData.add(ChartData(day, 0));
                                              incomeData.add(ChartData(day, 0));
                                            }
                                          } else if (filter[0] == '1') {
                                            DateTime now = DateTime.now();
                                            int lastDay = DateTime(now.year, now.month + 1, 0).day;

                                            for (int i = 1; i <= lastDay; i++) {
                                              expenseData.add(ChartData(i.toString(), 0));
                                              incomeData.add(ChartData(i.toString(), 0));
                                            }
                                          }
                                          
                                          return SfCartesianChart(
                                            primaryXAxis: CategoryAxis(),
                                            primaryYAxis: NumericAxis(minimum: 0),
                                            tooltipBehavior: _tooltip,
                                            legend: Legend(
                                              isVisible: true,
                                              position: LegendPosition.top
                                            ),
                                            series: <CartesianSeries<ChartData, String>>[
                                              ColumnSeries<ChartData, String>(
                                                dataSource: expenseData,
                                                xValueMapper: (ChartData data, _) => data.x,
                                                yValueMapper: (ChartData data, _) => data.y,
                                                name: 'Pengeluaran',
                                                color: Color.fromRGBO(214, 22, 22, 1)
                                              ),
                                              ColumnSeries<ChartData, String>(
                                                dataSource: incomeData,
                                                xValueMapper: (ChartData data, _) => data.x,
                                                yValueMapper: (ChartData data, _) => data.y,
                                                name: 'Pendapatan',
                                                color: Color.fromRGBO(34, 149, 11, 1)
                                              ),
                                            ]
                                          );
                                        }

                                        String mainCurrency = userController.user?.mainCurrency ?? '';

                                        Set<String> uniqueCurrencies = {};
                                        for (var doc in snapshot.data!.docs) {
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
                                        List<String> uniqueCurrenciesList = uniqueCurrencies.toList();

                                        Future<Map<String, dynamic>> conversionRates = currencyService.conversionRate(mainCurrency, uniqueCurrenciesList, 'now');

                                        return FutureBuilder<Map<String, dynamic>>(
                                          future: conversionRates,
                                          builder: (context, futureSnapshot) {
                                            if (futureSnapshot.hasError) {
                                              return Text("Error fetching conversion rates");
                                            }
                                            if (!futureSnapshot.hasData || futureSnapshot.data == null) {
                                              List<ChartData> expenseData = [];
                                              List<ChartData> incomeData = [];

                                              if (filter[0] == '0') {
                                                List<String> weekDays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                                                for (var day in weekDays) {
                                                  expenseData.add(ChartData(day, 0));
                                                  incomeData.add(ChartData(day, 0));
                                                }
                                              } else if (filter[0] == '1') {
                                                DateTime now = DateTime.now();
                                                int lastDay = DateTime(now.year, now.month + 1, 0).day;

                                                for (int i = 1; i <= lastDay; i++) {
                                                  expenseData.add(ChartData(i.toString(), 0));
                                                  incomeData.add(ChartData(i.toString(), 0));
                                                }
                                              }
                                              
                                              return SfCartesianChart(
                                                primaryXAxis: CategoryAxis(),
                                                primaryYAxis: NumericAxis(minimum: 0),
                                                tooltipBehavior: _tooltip,
                                                legend: Legend(
                                                  isVisible: true,
                                                  position: LegendPosition.top
                                                ),
                                                series: <CartesianSeries<ChartData, String>>[
                                                  ColumnSeries<ChartData, String>(
                                                    dataSource: expenseData,
                                                    xValueMapper: (ChartData data, _) => data.x,
                                                    yValueMapper: (ChartData data, _) => data.y,
                                                    name: 'Pengeluaran',
                                                    color: Color.fromRGBO(214, 22, 22, 1)
                                                  ),
                                                  ColumnSeries<ChartData, String>(
                                                    dataSource: incomeData,
                                                    xValueMapper: (ChartData data, _) => data.x,
                                                    yValueMapper: (ChartData data, _) => data.y,
                                                    name: 'Pendapatan',
                                                    color: Color.fromRGBO(34, 149, 11, 1)
                                                  ),
                                                ]
                                              );
                                            }

                                            List<ChartData> expenseData = [];
                                            List<ChartData> incomeData = [];

                                            if (filter[0] == '0') {
                                              List<String> weekDays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                                              for (var day in weekDays) {
                                                expenseData.add(ChartData(day, 0));
                                                incomeData.add(ChartData(day, 0));
                                              }
                                            } else if (filter[0] == '1') {
                                              DateTime now = DateTime.now();
                                              int lastDay = DateTime(now.year, now.month + 1, 0).day;

                                              for (int i = 1; i <= lastDay; i++) {
                                                expenseData.add(ChartData(i.toString(), 0));
                                                incomeData.add(ChartData(i.toString(), 0));
                                              }
                                            }

                                            var rates = futureSnapshot.data!['rates'];

                                            for (var doc in snapshot.data!.docs) {
                                              DateTime date = (doc['Date'] as Timestamp).toDate().toUtc().add(Duration(hours: 7));

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

                                                int index = -1;
                                                if (filter[0] == '0') {
                                                  index = date.weekday;
                                                } else if (filter[0] == '1') {
                                                  index = date.day;
                                                }
                                                
                                                if(doc['Type_Id'] == 0 || doc['Type_Id'] == 2) {
                                                  expenseData[index - 1].y += (currency == mainCurrency ? amount : (amount * rates[currency]));
                                                } else {
                                                  incomeData[index - 1].y += (currency == mainCurrency ? amount : (amount * rates[currency]));
                                                }
                                              }
                                            }

                                            return SfCartesianChart(
                                              primaryXAxis: CategoryAxis(),
                                              primaryYAxis: NumericAxis(minimum: 0),
                                              tooltipBehavior: _tooltip,
                                              legend: Legend(
                                                isVisible: true,
                                                position: LegendPosition.top
                                              ),
                                              series: <CartesianSeries<ChartData, String>>[
                                                ColumnSeries<ChartData, String>(
                                                  dataSource: expenseData,
                                                  xValueMapper: (ChartData data, _) => data.x,
                                                  yValueMapper: (ChartData data, _) => data.y,
                                                  name: 'Pengeluaran',
                                                  color: Color.fromRGBO(214, 22, 22, 1)
                                                ),
                                                ColumnSeries<ChartData, String>(
                                                  dataSource: incomeData,
                                                  xValueMapper: (ChartData data, _) => data.x,
                                                  yValueMapper: (ChartData data, _) => data.y,
                                                  name: 'Pendapatan',
                                                  color: Color.fromRGBO(34, 149, 11, 1)
                                                ),
                                              ]
                                            );
                                          }
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ) :
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SizedBox(
                              width: double.infinity,
                              child: Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: mainBlueMinusFour,
                                  borderRadius: borderRadius
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rasio Utang',
                                      style: TextStyle(
                                        fontSize: regular,
                                        color: greyMinusTwo
                                      ),
                                    ),
                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance.collection('Accounts').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return Text("Error");
                                        }
                                        if (!snapshot.hasData || snapshot.data == null) {
                                          return Text(
                                            '0',
                                            style: TextStyle(
                                              fontSize: semiLarge
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
                                                  fontSize: semiLarge
                                                )
                                              );
                                            }

                                            var rates = futureSnapshot.data!['rates'];
                                            currencyController.setCurrencies(uniqueCurrenciesList);
                                            double total = 0;

                                            for (var doc in snapshot.data!.docs) {
                                              String currency = doc['Currency'] ?? '';
                                              double amount = doc['Amount']?.toDouble() ?? 0.0;

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
                                                      fontSize: verySmall
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
                                                          fontSize: verySmall
                                                        )
                                                      );
                                                    }

                                                    var rates = futureSnapshot.data!['rates'];
                                                    double debt = 0;

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
                                                            debt += amount;
                                                          } else {
                                                            debt += (amount * rates[currency]);
                                                          }
                                                        }
                                                      }
                                                    }

                                                    return Text(
                                                      '${NumberFormat('#,##0.##', 'de_DE').format(debt / total)}%',
                                                      style: TextStyle(
                                                        fontSize: semiLarge
                                                      )
                                                    );
                                                  }
                                                );
                                              },
                                            );
                                          }
                                        );
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.all(12.5),
                                              margin: EdgeInsets.only(right: 7.5),
                                              decoration: BoxDecoration(
                                                color: redMinusTwo,
                                                borderRadius: borderRadiusMinusOne,
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 5),
                                                    child: Text(
                                                      "Total Utang",
                                                      style: TextStyle(
                                                        fontSize: semiVerySmall,
                                                        fontWeight: FontWeight.w500,
                                                        color: redPlusOne
                                                      ),
                                                    ),
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
                                                                fontSize: verySmall
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
                                                                    fontSize: verySmall
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
                                                                  fontSize: verySmall
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
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.all(12.5),
                                              margin: EdgeInsets.only(left: 7.5),
                                              decoration: BoxDecoration(
                                                color: greenMinusTwo,
                                                borderRadius: borderRadiusMinusOne,
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 5),
                                                    child: Text(
                                                      "Total Uang",
                                                      style: TextStyle(
                                                        fontSize: semiVerySmall,
                                                        fontWeight: FontWeight.w500,
                                                        color: greenPlusOne
                                                      ),
                                                    ),
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
                                                        stream: FirebaseFirestore.instance.collection('Accounts').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).snapshots(),
                                                        builder: (context, snapshot) {
                                                          if (snapshot.hasError) {
                                                            return Text("Error");
                                                          }
                                                          if (!snapshot.hasData || snapshot.data == null) {
                                                            return Text(
                                                              '0',
                                                              style: TextStyle(
                                                                color: mainBlue,
                                                                fontSize: semiLarge
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
                                                                    fontSize: verySmall
                                                                  )
                                                                );
                                                              }

                                                              var rates = futureSnapshot.data!['rates'];
                                                              currencyController.setCurrencies(uniqueCurrenciesList);
                                                              double total = 0;

                                                              for (var doc in snapshot.data!.docs) {
                                                                String currency = doc['Currency'] ?? '';
                                                                double amount = doc['Amount']?.toDouble() ?? 0.0;

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
                                                                  fontSize: verySmall
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
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SizedBox(
                              width: double.infinity,
                              child: Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: mainBlueMinusFour,
                                  borderRadius: borderRadius
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          // Time
                                          Padding(
                                            padding: const EdgeInsets.only(right: 7.5),
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                border: Border.all(color: mainBlue, width: 1),
                                                borderRadius: borderRadius,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 12.5),
                                                child: DropdownButtonHideUnderline(
                                                  child: SizedBox(
                                                    height: 35,
                                                    child: DropdownButton<String>(
                                                      value: filter[1],
                                                      items: [
                                                        DropdownMenuItem(
                                                          child: Text('Minggu Ini'),
                                                          value: '0',
                                                        ),
                                                        DropdownMenuItem(
                                                          child: Text('Bulan Ini'),
                                                          value: '1',
                                                        ),
                                                      ],
                                                      onChanged: (value) {
                                                        setState(() {
                                                          filter[1] = value ?? '';
                                                        });
                                                      },
                                                      style: TextStyle(color: mainBlue, fontSize: tiny),
                                                      iconEnabledColor: mainBlue,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
          
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Jumlah Transaksi',
                                            style: TextStyle(
                                              fontSize: regular,
                                              color: greyMinusTwo
                                            ),
                                          ),
                                          StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance.collection('Transactions').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).where('Date', isGreaterThanOrEqualTo: filter[1] == '0' ? startOfWeek : startOfMonth).where('Date', isLessThanOrEqualTo: filter[1] == '0' ? endOfWeek : endOfMonth).snapshots(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasError) {
                                                return Text("Error");
                                              }
                                              if (!snapshot.hasData || snapshot.data == null) {
                                                return Text(
                                                  '0',
                                                  style: TextStyle(
                                                    fontSize: semiLarge
                                                  )
                                                );
                                              }

                                              var docs = snapshot.data!.docs;

                                              return Text(
                                                NumberFormat('#,##0.###', 'de_DE').format(docs.length),
                                                style: TextStyle(
                                                  fontSize: semiLarge
                                                )
                                              );
                                            },
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    padding: EdgeInsets.all(12.5),
                                                    margin: EdgeInsets.only(right: 7.5),
                                                    decoration: BoxDecoration(
                                                      color: redMinusTwo,
                                                      borderRadius: borderRadiusMinusOne,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(bottom: 5),
                                                          child: Text(
                                                            "Pengeluaran",
                                                            style: TextStyle(
                                                              fontSize: semiVerySmall,
                                                              fontWeight: FontWeight.w500,
                                                              color: redPlusOne
                                                            ),
                                                          ),
                                                        ),
                                                        StreamBuilder<QuerySnapshot>(
                                                          stream: FirebaseFirestore.instance.collection('Transactions').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).where('Type_Id', isEqualTo: 0).where('Date', isGreaterThanOrEqualTo: filter[1] == '0' ? startOfWeek : startOfMonth).where('Date', isLessThanOrEqualTo: filter[1] == '0' ? endOfWeek : endOfMonth).snapshots(),
                                                          builder: (context, snapshot) {
                                                            if (snapshot.hasError) {
                                                              return Text("Error");
                                                            }
                                                            if (!snapshot.hasData || snapshot.data == null) {
                                                              return Text(
                                                                '0',
                                                                style: TextStyle(
                                                                  color: greyMinusTwo,
                                                                  fontSize: verySmall
                                                                )
                                                              );
                                                            }

                                                            var docs = snapshot.data!.docs;

                                                            return Text(
                                                              NumberFormat('#,##0.###', 'de_DE').format(docs.length),
                                                              style: TextStyle(
                                                                color: greyMinusTwo,
                                                                fontSize: verySmall
                                                              )
                                                            );
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    padding: EdgeInsets.all(12.5),
                                                    margin: EdgeInsets.only(left: 7.5),
                                                    decoration: BoxDecoration(
                                                      color: greenMinusTwo,
                                                      borderRadius: borderRadiusMinusOne,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(bottom: 5),
                                                          child: Text(
                                                            "Pendapatan",
                                                            style: TextStyle(
                                                              fontSize: semiVerySmall,
                                                              fontWeight: FontWeight.w500,
                                                              color: greenPlusOne
                                                            ),
                                                          ),
                                                        ),
                                                        StreamBuilder<QuerySnapshot>(
                                                          stream: FirebaseFirestore.instance.collection('Transactions').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).where('Type_Id', isEqualTo: 1).where('Date', isGreaterThanOrEqualTo: filter[1] == '0' ? startOfWeek : startOfMonth).where('Date', isLessThanOrEqualTo: filter[1] == '0' ? endOfWeek : endOfMonth).snapshots(),
                                                          builder: (context, snapshot) {
                                                            if (snapshot.hasError) {
                                                              return Text("Error");
                                                            }
                                                            if (!snapshot.hasData || snapshot.data == null) {
                                                              return Text(
                                                                '0',
                                                                style: TextStyle(
                                                                  color: greyMinusTwo,
                                                                  fontSize: verySmall
                                                                )
                                                              );
                                                            }

                                                            var docs = snapshot.data!.docs;

                                                            return Text(
                                                              NumberFormat('#,##0.###', 'de_DE').format(docs.length),
                                                              style: TextStyle(
                                                                color: greyMinusTwo,
                                                                fontSize: verySmall
                                                              )
                                                            );
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    );
                })
              ],
            ),
          ),
        ),
      )
    );
  }
}