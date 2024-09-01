import 'package:exinflow/widgets/padding.dart';
import 'package:exinflow/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Manage extends StatelessWidget {
  List<Map> features = [
    {
      'path': '/manage/transactions',
      'name': 'Transaksi',
      // 'description': 'Semua transaksi, templat transaksi, dan rencana transaksi',
      'description': 'Semua transaksi dan rencana transaksi',
      'icon': Icon(
        Icons.loop_rounded,
        color: Colors.white,
        size: 30
      ),
      'color': mainBlue,
      'lightColor': mainBlueMinusThree
    },
    {
      'path': '/manage/savings',
      'name': 'Tabungan',
      'description': 'Semua tabungan dan catatan tabungan',
      'icon': Icon(
        Icons.savings_outlined,
        color: Colors.white,
        size: 30
      ),
      'color': mainBlue,
      'lightColor': mainBlueMinusThree
    },
    // {
    //   'path': '/manage/budgets',
    //   'name': 'Anggaran',
    //   'description': 'Semua anggaran dan rencana anggaran',
    //   'icon': Icon(
    //     Icons.calculate_outlined,
    //     color: Colors.white,
    //     size: 30
    //   ),
    //   'color': mainBlue,
    //   'lightColor': mainBlueMinusThree
    // },
    {
      'path': '/manage/credits',
      'name': 'Kredit',
      // 'description': 'Semua penyedia, tagihan, dan cicilan kredit',
      'description': 'Semua penyedia dan tagihan kredit',
      'icon': Icon(
        Icons.payment_outlined,
        color: Colors.white,
        size: 30
      ),
      'color': mainBlue,
      'lightColor': mainBlueMinusThree
    },
    {
      'path': '/manage/accounts',
      'name': 'Akun',
      'description': 'Semua akun',
      'icon': Icon(
        Icons.account_balance_outlined,
        color: Colors.white,
        size: 30
      ),
      'color': mainBlue,
      'lightColor': mainBlueMinusThree
    },
    {
      'path': '/manage/categories',
      'name': 'Kategori',
      'description': 'Semua kategori dan subkategori',
      'icon': Icon(
        Icons.loyalty_outlined,
        color: Colors.white,
        size: 30
      ),
      'color': mainBlue,
      'lightColor': mainBlueMinusThree
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: AllPadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Text(
                    "Atur",
                    style: TextStyle(
                      fontSize: large,
                      color: mainBluePlusOne,
                      fontFamily: "Open Sans",
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),

                ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: List.generate(
                    features.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: index != features.length - 1 ? 15 : 0),
                      child: InkWell(
                        onTap: () {
                          context.push(features[index]['path']);
                        },
                        child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: borderRadius,
                            color: features[index]['lightColor']
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: features[index]['color']
                                ),
                                child: features[index]['icon'],
                              ),
                        
                              Container(
                                width: 275,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 2.5),
                                      child: Text(
                                        features[index]['name'],
                                        style: TextStyle(
                                          color: mainBlue,
                                          fontSize: small,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Open Sans"
                                        )
                                      ),
                                    ),
                                    Text(
                                      features[index]['description'],
                                      style: TextStyle(
                                        fontSize: tiny,
                                        color: greyMinusOne,
                                        height: 1.25
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ),
                      ),
                    )
                  ),
                )
              ],
            ),
          )
        ),
      )
    );
  }
}