import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:exinflow/constants/constants.dart';
import 'package:exinflow/widgets/padding.dart';
import 'package:exinflow/widgets/alert.dart';

class SpeechRecognition extends StatefulWidget {
  @override
  State<SpeechRecognition> createState() => _SpeechRecognitionState();
}

class _SpeechRecognitionState extends State<SpeechRecognition> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AllPadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () {
                  context.pop();
                },
                style: OutlinedButton.styleFrom(
                  shape: CircleBorder(),
                  side: BorderSide(width: 1, color: mainBlue),
                  padding: EdgeInsets.zero,
                  minimumSize: Size(45, 45),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: mainBlue,
                  size: 35
                ),
              ),

              Text(
                "Ucapkan Sesuatu",
                style: TextStyle(
                  fontSize: semiLarge,
                  color: mainBluePlusOne,
                  fontFamily: "Open Sans",
                  fontWeight: FontWeight.w600
                ),
              ),

              Container(
                height: 500,
                padding: EdgeInsets.only(top: 10, right: 10, left: 10),
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  color: greyMinusFive
                ),
                child: ListView(
                  children: <Widget>[
                    ExpansionTile(
                      title: Text(
                        'Tambah',
                        style: TextStyle(
                          fontSize: regular
                        ),
                      ),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 242, 242, 242),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Container(
                              width: double.infinity,
                              child: Text(''),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(
                          'Lihat',
                          style: TextStyle(
                            fontSize: regular
                          ),
                        ),
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 242, 242, 242),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.all(16),
                              child: Container(
                                margin: EdgeInsets.only(bottom: 10),
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 7.5),
                                            child: Text(
                                              'Transaksi',
                                              style: TextStyle(
                                                fontSize: small,
                                                color: greyMinusTwo
                                              )
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: 7.5),
                                                child: Icon(
                                                  Icons.record_voice_over_outlined,
                                                  color: greyMinusThree
                                                ),
                                              ),
                                              Text(
                                                '"Semua transaksi saya"',
                                                style: TextStyle(
                                                  fontSize: verySmall,
                                                  color: greyMinusThree
                                                )
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 7.5),
                                            child: Text(
                                              'Tabungan',
                                              style: TextStyle(
                                                fontSize: small,
                                                color: greyMinusTwo
                                              )
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: 7.5),
                                                child: Icon(
                                                  Icons.record_voice_over_outlined,
                                                  color: greyMinusThree
                                                ),
                                              ),
                                              Text(
                                                '"Semua tabungan saya"',
                                                style: TextStyle(
                                                  fontSize: verySmall,
                                                  color: greyMinusThree
                                                )
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 7.5),
                                            child: Text(
                                              'Catatan Tabungan',
                                              style: TextStyle(
                                                fontSize: small,
                                                color: greyMinusTwo
                                              )
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: 7.5),
                                                child: Icon(
                                                  Icons.record_voice_over_outlined,
                                                  color: greyMinusThree
                                                ),
                                              ),
                                              Text(
                                                '"Semua catatan tabungan saya"',
                                                style: TextStyle(
                                                  fontSize: verySmall,
                                                  color: greyMinusThree
                                                )
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 7.5),
                                            child: Text(
                                              'Kredit',
                                              style: TextStyle(
                                                fontSize: small,
                                                color: greyMinusTwo
                                              )
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: 7.5),
                                                child: Icon(
                                                  Icons.record_voice_over_outlined,
                                                  color: greyMinusThree
                                                ),
                                              ),
                                              Text(
                                                '"Semua kredit saya"',
                                                style: TextStyle(
                                                  fontSize: verySmall,
                                                  color: greyMinusThree
                                                )
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 7.5),
                                            child: Text(
                                              'Tagihan Kredit',
                                              style: TextStyle(
                                                fontSize: small,
                                                color: greyMinusTwo
                                              )
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: 7.5),
                                                child: Icon(
                                                  Icons.record_voice_over_outlined,
                                                  color: greyMinusThree
                                                ),
                                              ),
                                              Text(
                                                '"Semua transaksi saya"',
                                                style: TextStyle(
                                                  fontSize: verySmall,
                                                  color: greyMinusThree
                                                )
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 7.5),
                                            child: Text(
                                              'Transaksi',
                                              style: TextStyle(
                                                fontSize: small,
                                                color: greyMinusTwo
                                              )
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: 7.5),
                                                child: Icon(
                                                  Icons.record_voice_over_outlined,
                                                  color: greyMinusThree
                                                ),
                                              ),
                                              Text(
                                                '"Semua transaksi saya"',
                                                style: TextStyle(
                                                  fontSize: verySmall,
                                                  color: greyMinusThree
                                                )
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 7.5),
                                            child: Text(
                                              'Transaksi',
                                              style: TextStyle(
                                                fontSize: small,
                                                color: greyMinusTwo
                                              )
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: 7.5),
                                                child: Icon(
                                                  Icons.record_voice_over_outlined,
                                                  color: greyMinusThree
                                                ),
                                              ),
                                              Text(
                                                '"Semua transaksi saya"',
                                                style: TextStyle(
                                                  fontSize: verySmall,
                                                  color: greyMinusThree
                                                )
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Alert.show(context, {
                        'success': true,
                        'message': 'Berhasil menambah transaksi baru'
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      shape: CircleBorder(),
                      side: BorderSide(width: 1, color: mainBlue),
                      padding: EdgeInsets.zero,
                      minimumSize: Size(60, 60),
                      backgroundColor: mainBlue
                    ),
                    child: Icon(
                      Icons.square_rounded,
                      color: Colors.white,
                      size: 20
                    ),
                  ),
                ],
              )
            ]
          )
        )
      )
    );
  }
}