import 'package:exinflow/controllers/subtab.dart';
import 'package:exinflow/widgets/padding.dart';
import 'package:exinflow/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:exinflow/widgets/subtab.dart';
import 'package:get/get.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async'; 

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
  final AllSubtabController allSubtabController = Get.find<AllSubtabController>();
  late TabController analyticsTabController;
  late StreamSubscription<int> selectedTabSubscription;

  late List<_ChartData> data;
  // late TooltipBehavior _tooltip;

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
    
    data = [
      _ChartData('Sen', 25000),
      _ChartData('Sel', 1160000),
      _ChartData('Rab', 250300),
      _ChartData('Kam', 984000),
      _ChartData('Jum', 14000),
      _ChartData('Sab', 358300),
      _ChartData('Min', 2300000)
    ];
    // _tooltip = TooltipBehavior(enable: true);

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
                                                      value: 'Minggu Ini',
                                                      items: [
                                                        DropdownMenuItem(
                                                          child: Text('Minggu Ini'),
                                                          value: 'Minggu Ini',
                                                        ),
                                                      ],
                                                      onChanged: (value) {
                                                        // Handle change
                                                      },
                                                      style: TextStyle(color: mainBlue, fontSize: tiny),
                                                      iconEnabledColor: mainBlue,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          
                                          // // Per
                                          // Padding(
                                          //   padding: const EdgeInsets.only(right: 7.5),
                                          //   child: DecoratedBox(
                                          //     decoration: BoxDecoration(
                                          //       border: Border.all(color: mainBlue, width: 1),
                                          //       borderRadius: borderRadius,
                                          //     ),
                                          //     child: Padding(
                                          //       padding: const EdgeInsets.symmetric(horizontal: 12.5),
                                          //       child: DropdownButtonHideUnderline(
                                          //         child: SizedBox(
                                          //           height: 35,
                                          //           child: DropdownButton<String>(
                                          //             value: 'Per Hari',
                                          //             items: [
                                          //               DropdownMenuItem(
                                          //                 child: Text('Per Hari'),
                                          //                 value: 'Per Hari',
                                          //               ),
                                          //             ],
                                          //             onChanged: (value) {
                                          //               // Handle change
                                          //             },
                                          //             style: TextStyle(color: mainBlue, fontSize: tiny),
                                          //             iconEnabledColor: mainBlue,
                                          //           ),
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
          
                                          // // Category
                                          // Padding(
                                          //   padding: const EdgeInsets.only(right: 7.5),
                                          //   child: DecoratedBox(
                                          //     decoration: BoxDecoration(
                                          //       border: Border.all(color: mainBlue, width: 1),
                                          //       borderRadius: borderRadius,
                                          //     ),
                                          //     child: Padding(
                                          //       padding: const EdgeInsets.symmetric(horizontal: 12.5),
                                          //       child: DropdownButtonHideUnderline(
                                          //         child: SizedBox(
                                          //           height: 35,
                                          //           child: DropdownButton<String>(
                                          //             value: 'Semua Kategori',
                                          //             items: [
                                          //               DropdownMenuItem(
                                          //                 child: Text('Semua Kategori'),
                                          //                 value: 'Semua Kategori',
                                          //               ),
                                          //             ],
                                          //             onChanged: (value) {
                                          //               // Handle change
                                          //             },
                                          //             style: TextStyle(color: mainBlue, fontSize: tiny),
                                          //             iconEnabledColor: mainBlue,
                                          //           ),
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
          
                                          // // Account and Credit
                                          // DecoratedBox(
                                          //   decoration: BoxDecoration(
                                          //     border: Border.all(color: mainBlue, width: 1),
                                          //     borderRadius: borderRadius,
                                          //   ),
                                          //   child: Padding(
                                          //     padding: const EdgeInsets.symmetric(horizontal: 12.5),
                                          //     child: DropdownButtonHideUnderline(
                                          //       child: SizedBox(
                                          //         height: 35,
                                          //         child: DropdownButton<String>(
                                          //           value: 'Semua Akun dan Kredit',
                                          //           items: [
                                          //             DropdownMenuItem(
                                          //               child: Text('Semua Akun dan Kredit'),
                                          //               value: 'Semua Akun dan Kredit',
                                          //             ),
                                          //           ],
                                          //           onChanged: (value) {
                                          //             // Handle change
                                          //           },
                                          //           style: TextStyle(color: mainBlue, fontSize: tiny),
                                          //           iconEnabledColor: mainBlue,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
          
                                    // Padding(
                                    //   padding: const EdgeInsets.only(top: 30),
                                    //   child: SfCartesianChart(
                                    //     primaryXAxis: CategoryAxis(),
                                    //     primaryYAxis: NumericAxis(minimum: 0, maximum: 2500000, interval: 500000),
                                    //     tooltipBehavior: _tooltip,
                                    //     series: <CartesianSeries<_ChartData, String>>[
                                    //       ColumnSeries<_ChartData, String>(
                                    //         dataSource: data,
                                    //         xValueMapper: (_ChartData data, _) => data.x,
                                    //         yValueMapper: (_ChartData data, _) => data.y,
                                    //         name: 'Gold',
                                    //         color: Color.fromRGBO(8, 142, 255, 1)
                                    //       )
                                    //     ]
                                    //   )
                                    // )
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
                                                      value: 'Minggu Ini',
                                                      items: [
                                                        DropdownMenuItem(
                                                          child: Text('Minggu Ini'),
                                                          value: 'Minggu Ini',
                                                        ),
                                                      ],
                                                      onChanged: (value) {
                                                        // Handle change
                                                      },
                                                      style: TextStyle(color: mainBlue, fontSize: tiny),
                                                      iconEnabledColor: mainBlue,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          
                                          // // Per
                                          // Padding(
                                          //   padding: const EdgeInsets.only(right: 7.5),
                                          //   child: DecoratedBox(
                                          //     decoration: BoxDecoration(
                                          //       border: Border.all(color: mainBlue, width: 1),
                                          //       borderRadius: borderRadius,
                                          //     ),
                                          //     child: Padding(
                                          //       padding: const EdgeInsets.symmetric(horizontal: 12.5),
                                          //       child: DropdownButtonHideUnderline(
                                          //         child: SizedBox(
                                          //           height: 35,
                                          //           child: DropdownButton<String>(
                                          //             value: 'Per Hari',
                                          //             items: [
                                          //               DropdownMenuItem(
                                          //                 child: Text('Per Hari'),
                                          //                 value: 'Per Hari',
                                          //               ),
                                          //             ],
                                          //             onChanged: (value) {
                                          //               // Handle change
                                          //             },
                                          //             style: TextStyle(color: mainBlue, fontSize: tiny),
                                          //             iconEnabledColor: mainBlue,
                                          //           ),
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
          
                                          // // Category
                                          // Padding(
                                          //   padding: const EdgeInsets.only(right: 7.5),
                                          //   child: DecoratedBox(
                                          //     decoration: BoxDecoration(
                                          //       border: Border.all(color: mainBlue, width: 1),
                                          //       borderRadius: borderRadius,
                                          //     ),
                                          //     child: Padding(
                                          //       padding: const EdgeInsets.symmetric(horizontal: 12.5),
                                          //       child: DropdownButtonHideUnderline(
                                          //         child: SizedBox(
                                          //           height: 35,
                                          //           child: DropdownButton<String>(
                                          //             value: 'Semua Kategori',
                                          //             items: [
                                          //               DropdownMenuItem(
                                          //                 child: Text('Semua Kategori'),
                                          //                 value: 'Semua Kategori',
                                          //               ),
                                          //             ],
                                          //             onChanged: (value) {
                                          //               // Handle change
                                          //             },
                                          //             style: TextStyle(color: mainBlue, fontSize: tiny),
                                          //             iconEnabledColor: mainBlue,
                                          //           ),
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
          
                                          // // Account and Credit
                                          // DecoratedBox(
                                          //   decoration: BoxDecoration(
                                          //     border: Border.all(color: mainBlue, width: 1),
                                          //     borderRadius: borderRadius,
                                          //   ),
                                          //   child: Padding(
                                          //     padding: const EdgeInsets.symmetric(horizontal: 12.5),
                                          //     child: DropdownButtonHideUnderline(
                                          //       child: SizedBox(
                                          //         height: 35,
                                          //         child: DropdownButton<String>(
                                          //           value: 'Semua Akun dan Kredit',
                                          //           items: [
                                          //             DropdownMenuItem(
                                          //               child: Text('Semua Akun dan Kredit'),
                                          //               value: 'Semua Akun dan Kredit',
                                          //             ),
                                          //           ],
                                          //           onChanged: (value) {
                                          //             // Handle change
                                          //           },
                                          //           style: TextStyle(color: mainBlue, fontSize: tiny),
                                          //           iconEnabledColor: mainBlue,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
          
                                    // Padding(
                                    //   padding: const EdgeInsets.only(top: 20),
                                    //   child: SfCartesianChart(
                                    //     primaryXAxis: CategoryAxis(),
                                    //     primaryYAxis: NumericAxis(minimum: 0, maximum: 2500000, interval: 500000),
                                    //     tooltipBehavior: _tooltip,
                                    //     series: <CartesianSeries<_ChartData, String>>[
                                    //       ColumnSeries<_ChartData, String>(
                                    //         dataSource: data,
                                    //         xValueMapper: (_ChartData data, _) => data.x,
                                    //         yValueMapper: (_ChartData data, _) => data.y,
                                    //         name: 'Gold',
                                    //         color: Color.fromRGBO(8, 142, 255, 1)
                                    //       )
                                    //     ]
                                    //   )
                                    // )
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
                                                      Text(
                                                        'Rp11.541.540',
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
                                                      value: 'Minggu Ini',
                                                      items: [
                                                        DropdownMenuItem(
                                                          child: Text('Minggu Ini'),
                                                          value: 'Minggu Ini',
                                                        ),
                                                      ],
                                                      onChanged: (value) {
                                                        // Handle change
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