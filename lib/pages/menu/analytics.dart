import 'package:exinflow/controllers/subtab.dart';
import 'package:exinflow/widgets/padding.dart';
import 'package:exinflow/constants/constants.dart';
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

class _ChartData {
  _ChartData(this.x, this.y);
 
  final String x;
  final double y;
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
  List<String> filter = ['0', '0', '0'];

  late List<_ChartData> expenseWeeklyData;
  late List<_ChartData> incomeWeeklyData;
  late List<_ChartData> expenseMonthlyData;
  late List<_ChartData> incomeMonthlyData;
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

    expenseWeeklyData = [
      _ChartData('Sen', 0),
      _ChartData('Sel', 0),
      _ChartData('Rab', 0),
      _ChartData('Kam', 0),
      _ChartData('Jum', 0),
      _ChartData('Sab', 0),
      _ChartData('Min', 0)
    ];
    incomeWeeklyData = [
      _ChartData('Sen', 45000),
      _ChartData('Sel', 0),
      _ChartData('Rab', 0),
      _ChartData('Kam', 0),
      _ChartData('Jum', 15000),
      _ChartData('Sab', 0),
      _ChartData('Min', 0)
    ];
    expenseMonthlyData = [
      _ChartData('1', 0),
      _ChartData('2', 0),
      _ChartData('3', 0),
      _ChartData('4', 0),
      _ChartData('5', 23000),
      _ChartData('6', 0),
      _ChartData('7', 0),
      _ChartData('8', 0),
      _ChartData('9', 0),
      _ChartData('10', 0),
      _ChartData('11', 12000),
      _ChartData('12', 0),
      _ChartData('13', 0),
      _ChartData('14', 670000),
      _ChartData('15', 0),
      _ChartData('16', 0),
      _ChartData('17', 0),
      _ChartData('18', 0),
      _ChartData('19', 0),
      _ChartData('20', 0),
      _ChartData('21', 0),
      _ChartData('22', 0),
      _ChartData('23', 0),
      _ChartData('24', 0),
      _ChartData('25', 0),
      _ChartData('26', 0),
      _ChartData('27', 0),
      _ChartData('28', 0),
      _ChartData('29', 0),
      _ChartData('30', 0),
    ];
    incomeMonthlyData = [
      _ChartData('1', 0),
      _ChartData('2', 0),
      _ChartData('3', 0),
      _ChartData('4', 0),
      _ChartData('5', 0),
      _ChartData('6', 0),
      _ChartData('7', 0),
      _ChartData('8', 0),
      _ChartData('9', 250000),
      _ChartData('10', 0),
      _ChartData('11', 0),
      _ChartData('12', 0),
      _ChartData('13', 0),
      _ChartData('14', 30000),
      _ChartData('15', 0),
      _ChartData('16', 0),
      _ChartData('17', 0),
      _ChartData('18', 0),
      _ChartData('19', 0),
      _ChartData('20', 0),
      _ChartData('21', 0),
      _ChartData('22', 0),
      _ChartData('23', 0),
      _ChartData('24', 0),
      _ChartData('25', 0),
      _ChartData('26', 0),
      _ChartData('27', 15000),
      _ChartData('28', 0),
      _ChartData('29', 0),
      _ChartData('30', 0),
    ];
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
                                        'Pengeluaran',
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
          
                                    Padding(
                                      padding: const EdgeInsets.only(top: 30),
                                      child: SfCartesianChart(
                                        primaryXAxis: CategoryAxis(),
                                        primaryYAxis: NumericAxis(minimum: 0, maximum: 200000, interval: 20000),
                                        tooltipBehavior: _tooltip,
                                        series: <CartesianSeries<_ChartData, String>>[
                                          ColumnSeries<_ChartData, String>(
                                            dataSource: filter[0] == '0' ? expenseWeeklyData : expenseMonthlyData,
                                            xValueMapper: (_ChartData data, _) => data.x,
                                            yValueMapper: (_ChartData data, _) => data.y,
                                            name: 'Gold',
                                            color: Color.fromRGBO(8, 142, 255, 1)
                                          )
                                        ]
                                      )
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
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        'Pendapatan',
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
                                      child: SfCartesianChart(
                                        primaryXAxis: CategoryAxis(),
                                        primaryYAxis: NumericAxis(minimum: 0, maximum: 200000, interval: 20000),
                                        tooltipBehavior: _tooltip,
                                        series: <CartesianSeries<_ChartData, String>>[
                                          ColumnSeries<_ChartData, String>(
                                            dataSource: filter[0] == '0' ? incomeWeeklyData : incomeMonthlyData,
                                            xValueMapper: (_ChartData data, _) => data.x,
                                            yValueMapper: (_ChartData data, _) => data.y,
                                            name: 'Gold',
                                            color: Color.fromRGBO(8, 142, 255, 1)
                                          )
                                        ]
                                      )
                                    )
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
                                    Text(
                                      '1 : 7.45',
                                      style: TextStyle(
                                        fontSize: semiLarge
                                      ),
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
                                                        'Rp1.549.200',
                                                        style: TextStyle(
                                                          color: greyMinusTwo,
                                                          fontSize: verySmall
                                                        ),
                                                      ),
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
                                                      value: filter[2],
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
                                                          filter[2] = value ?? '';
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
                                          Text(
                                            '15',
                                            style: TextStyle(
                                              fontSize: semiLarge
                                            ),
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
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Rp382.000',
                                                              style: TextStyle(
                                                                color: greyMinusTwo,
                                                                fontSize: verySmall
                                                              ),
                                                            ),
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
                                                            "Pendapatan",
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
                                                              'Rp801.800',
                                                              style: TextStyle(
                                                                color: greyMinusTwo,
                                                                fontSize: verySmall
                                                              ),
                                                            ),
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