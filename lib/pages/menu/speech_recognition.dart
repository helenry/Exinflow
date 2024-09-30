import 'package:exinflow/models/common.dart';
import 'package:exinflow/models/transaction.dart';
import 'package:exinflow/services/transaction.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:exinflow/constants/constants.dart';
import 'package:exinflow/widgets/padding.dart';
import 'package:exinflow/widgets/alert.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path/path.dart' as path;
import 'package:exinflow/services/speech_recognition.dart';
import 'package:exinflow/services/saving.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exinflow/models/saving.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exinflow/controllers/saving.dart';
import 'package:exinflow/controllers/account.dart';
import 'package:exinflow/controllers/category.dart';
import 'package:get/get.dart';

class SpeechRecognition extends StatefulWidget {
  @override
  State<SpeechRecognition> createState() => _SpeechRecognitionState();
}

class _SpeechRecognitionState extends State<SpeechRecognition> {
  final user = FirebaseAuth.instance.currentUser;
  bool isRecording = false;
  FlutterSoundRecorder? recorder;
  final SpeechRecognitionService speechRecognitionService = SpeechRecognitionService();
  final SavingService savingService = SavingService();
  final TransactionService transactionService = TransactionService();
  late Record record;
  late TransactionModel transaction;
  final CategoryController categoryController = Get.find<CategoryController>();
  final AccountController accountController = Get.find<AccountController>();
  final SavingController savingController = Get.find<SavingController>();

  @override
  void initState() {
    super.initState();
    recording();
  }

  Future<void> recording() async {
    PermissionStatus status = await Permission.microphone.status;

    if (status.isDenied) status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) openAppSettings();

    if (status.isGranted) {
      recorder = FlutterSoundRecorder();
      await recorder!.openRecorder();
      await startRecording();
    } else {
      context.pop();
    }
  }

  Future<void> startRecording() async {
    try {
      setState(() {
        isRecording = true;
      });

      final dir = await getApplicationDocumentsDirectory();
      final saveDir = Directory(path.join(dir.path, 'audio'));
      
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }

      final filePath = path.join(saveDir.path, 'speech.wav');
      
      await recorder!.startRecorder(
        toFile: filePath,
        codec: Codec.pcm16WAV
      );
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      setState(() {
        isRecording = false;
      });

      final dir = await getApplicationDocumentsDirectory();
      final saveDir = Directory(path.join(dir.path, 'audio'));
      final filePath = path.join(saveDir.path, 'speech.wav');

      await recorder!.stopRecorder();
      
      Map<String, dynamic> trueResult = await speechRecognitionService.getWords(filePath, true);
      Map<String, dynamic> falseResult = await speechRecognitionService.getWords(filePath, false);

      if(trueResult['success'] == true && falseResult['success'] == true) {
        if(trueResult['text'].split(' ')[0].toLowerCase() == 'tambah' || falseResult['text'].split(' ')[0].toLowerCase() == 'tambah') {
          Map<String, dynamic> result = {};
          String cleanedText = trueResult['text'].replaceAll(RegExp(r'[.,;:!?]*$'), '');

          if(trueResult['text'].split(' ')[1].toLowerCase() == 'transaksi' || falseResult['text'].split(' ')[1].toLowerCase() == 'transaksi') {
            if(trueResult['text'].split(' ')[2].toLowerCase() == 'uang' || falseResult['text'].split(' ')[2].toLowerCase() == 'uang') {
              final regex = RegExp(
                r'tambah transaksi uang (masuk|keluar) ([\d.,]+) (ke|dari) (\w+|\S+) kategori (\w+|\S+)', 
                caseSensitive: false,
              );

              final match = regex.firstMatch(cleanedText);

              if (match != null) {
                String? accountId;
                try {
                  accountId = accountController.accounts.firstWhere((account) => account.name.toLowerCase() == match.group(4)!.toLowerCase(),).id;
                } catch (e) {
                  accountId = '';
                }
                String? categoryId = '';
                try {
                  categoryId = categoryController.categories.firstWhere((category) => category.name.toLowerCase() == match.group(5)!.toLowerCase()).id;
                } catch (e) {
                  categoryId = '';
                }

                if(categoryId != '' && accountId != '') {
                  result = await transactionService.createTransaction(
                    user?.uid ?? '',
                    'transaction',
                    TransactionModel(
                      id: '',
                      amount: double.parse(match.group(2)!),
                      category: Category(id: categoryId, subId: null),
                      accountId: Account(
                        destination: match.group(1)! == 'keluar' ? null : accountId,
                        source: match.group(1)! == 'keluar' ? accountId : null
                      ),
                      typeId: match.group(1)! == 'keluar' ? 0 : 1,
                      fee: null,
                      note: null,
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
                    )
                  );
                } else {
                  result = {};
                }
              }
            } else {
              final regex = RegExp(
                r'tambah transaksi transfer ([\d.,]+) dari (\w+|\S+) ke (\w+|\S+)', 
                caseSensitive: false,
              );

              final match = regex.firstMatch(cleanedText);

              if (match != null) {
                String? sourceAccountId;
                try {
                  sourceAccountId = accountController.accounts.firstWhere((account) => account.name.toLowerCase() == match.group(2)!.toLowerCase(),).id;
                } catch (e) {
                  sourceAccountId = '';
                }
                String? destinationAccountId;
                try {
                  destinationAccountId = accountController.accounts.firstWhere((account) => account.name.toLowerCase() == match.group(3)!.toLowerCase(),).id;
                } catch (e) {
                  destinationAccountId = '';
                }

                if(sourceAccountId != '' && destinationAccountId != '') {
                  result = await transactionService.createTransaction(
                    user?.uid ?? '',
                    'transaction',
                    TransactionModel(
                      id: '',
                      amount: double.parse(match.group(1)!),
                      category: null,
                      accountId: Account(
                        destination: destinationAccountId,
                        source: sourceAccountId
                      ),
                      typeId: 2,
                      fee: null,
                      note: null,
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
                    )
                  );
                } else {
                  result = {};
                }
              }
            }
          }
          if(trueResult['text'].split(' ')[1].toLowerCase() == 'catatan' || falseResult['text'].split(' ')[1].toLowerCase() == 'catatan') {
            final regex = RegExp(
              r'tambah catatan tabungan (masuk|keluar) (\w+|\S+) ([\d.,]+) dari (\w+|\S+)', 
              caseSensitive: false,
            );

            final match = regex.firstMatch(cleanedText);

            if (match != null) {
              String? savingId = '';
              try {
                savingId = savingController.savings.firstWhere((saving) => saving.name.toLowerCase() == match.group(2)!.toLowerCase()).id;
              } catch (e) {
                savingId = '';
              }
              String? accountId;
              try {
                accountId = accountController.accounts.firstWhere((account) => account.name.toLowerCase() == match.group(4)!.toLowerCase(),).id;
              } catch (e) {
                accountId = '';
              }

              if(savingId != '' && accountId != '') {
                result = await savingService.createRecord(
                  user?.uid ?? '',
                  savingId,
                  Record(
                    amount: double.parse(match.group(3)!),
                    accountId: accountId,
                    typeId: match.group(1)! == 'keluar' ? 0 : 1,
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
                  )
                );
              } else {
                result = {};
              }
            }
          }

          print("result");
          print(result);

          if(result['success'] == true) {
            Alert.show(context, result, {
              'true': trueResult['text'].split(' ').length,
              'false': falseResult['text'].split(' ').length,
              'diff': (trueResult['text'].split(' ').length - falseResult['text'].split(' ').length).abs()
            });  
          } 
        } else {
          if(trueResult['text'].split(' ')[0].toLowerCase() == 'statistik' || falseResult['text'].split(' ')[0].toLowerCase() == 'statistik') {
            context.go('/analytics');
          }
          if(trueResult['text'].split(' ')[0].toLowerCase() == 'wawasan' || falseResult['text'].split(' ')[0].toLowerCase() == 'wawasan') {
            context.go('/analytics');
          }
          if(trueResult['text'].split(' ')[0].toLowerCase() == 'semua' || falseResult['text'].split(' ')[0].toLowerCase() == 'semua') {
            if(trueResult['text'].split(' ')[1].toLowerCase() == 'transaksi' || falseResult['text'].split(' ')[1].toLowerCase() == 'transaksi') {
              context.go('/manage/transactions');
            }
            if(trueResult['text'].split(' ')[1].toLowerCase() == 'tabungan' || falseResult['text'].split(' ')[1].toLowerCase() == 'tabungan') {
              context.go('/manage/savings');
            }
            if(trueResult['text'].split(' ')[1].toLowerCase() == 'catatan' || falseResult['text'].split(' ')[1].toLowerCase() == 'catatan') {
              context.go('/manage/savings');
            }
            if(trueResult['text'].split(' ')[1].toLowerCase() == 'kredit' || falseResult['text'].split(' ')[1].toLowerCase() == 'kredit') {
              context.go('/manage/credits');
            }
            if(trueResult['text'].split(' ')[1].toLowerCase() == 'tagihan' || falseResult['text'].split(' ')[1].toLowerCase() == 'tagihan') {
              context.go('/manage/credits');
            }
          }
        }
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    recorder?.closeRecorder();
  }

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
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(
                          'Tambah',
                          style: TextStyle(
                            fontSize: regular
                          ),
                        ),
                        initiallyExpanded: true,
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
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(bottom: 5),
                                                child: Text(
                                                  'Uang Masuk',
                                                  style: TextStyle(fontSize: verySmall, color: greyMinusThree),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 10),
                                                    child: Icon(
                                                      Icons.record_voice_over_outlined,
                                                      color: greyMinusThree
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 250,
                                                    child: Text.rich(
                                                      TextSpan(
                                                        text: 'Tambah transaksi uang masuk ',
                                                        style: TextStyle(fontSize: verySmall, color: greyMinusThree),
                                                        children: [
                                                          TextSpan(
                                                            text: '{jumlah uang}',
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                          ),
                                                          TextSpan(
                                                            text: ' ke ',
                                                          ),
                                                          TextSpan(
                                                            text: '{nama akun}',
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                          ),
                                                          TextSpan(
                                                            text: ' kategori ',
                                                          ),
                                                          TextSpan(
                                                            text: '{nama kategori}',
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(bottom: 5, top: 10),
                                                child: Text(
                                                  'Uang Keluar',
                                                  style: TextStyle(fontSize: verySmall, color: greyMinusThree),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 10),
                                                    child: Icon(
                                                      Icons.record_voice_over_outlined,
                                                      color: greyMinusThree
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 250,
                                                    child: Text.rich(
                                                      TextSpan(
                                                        text: 'Tambah transaksi uang keluar ',
                                                        style: TextStyle(fontSize: verySmall, color: greyMinusThree),
                                                        children: [
                                                          TextSpan(
                                                            text: '{jumlah uang}',
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                          ),
                                                          TextSpan(
                                                            text: ' dari ',
                                                          ),
                                                          TextSpan(
                                                            text: '{nama akun}',
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                          ),
                                                          TextSpan(
                                                            text: ' kategori ',
                                                          ),
                                                          TextSpan(
                                                            text: '{nama kategori}',
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(bottom: 5, top: 10),
                                                child: Text(
                                                  'Transfer',
                                                  style: TextStyle(fontSize: verySmall, color: greyMinusThree),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 10),
                                                    child: Icon(
                                                      Icons.record_voice_over_outlined,
                                                      color: greyMinusThree
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 250,
                                                    child: Text.rich(
                                                      TextSpan(
                                                        text: 'Tambah transaksi transfer ',
                                                        style: TextStyle(fontSize: verySmall, color: greyMinusThree),
                                                        children: [
                                                          TextSpan(
                                                            text: '{jumlah uang}',
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                          ),
                                                          TextSpan(
                                                            text: ' dari ',
                                                          ),
                                                          TextSpan(
                                                            text: '{nama akun asal}',
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                          ),
                                                          TextSpan(
                                                            text: ' ke ',
                                                          ),
                                                          TextSpan(
                                                            text: '{nama akun tujuan}',
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
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
                                          // Row(
                                          //   mainAxisAlignment: MainAxisAlignment.start,
                                          //   crossAxisAlignment: CrossAxisAlignment.start,
                                          //   children: [
                                          //     Padding(
                                          //       padding: const EdgeInsets.only(right: 10),
                                          //       child: Icon(
                                          //         Icons.record_voice_over_outlined,
                                          //         color: greyMinusThree
                                          //       ),
                                          //     ),
                                          //     Container(
                                          //       width: 250,
                                          //       child: Text.rich(
                                          //         TextSpan(
                                          //           text: 'Tambah catatan tabungan ',
                                          //           style: TextStyle(fontSize: verySmall, color: greyMinusThree),
                                          //           children: [
                                          //             TextSpan(
                                          //               text: '{masuk/keluar}',
                                          //               style: TextStyle(fontWeight: FontWeight.bold),
                                          //             ),
                                          //             TextSpan(
                                          //               text: ' ',
                                          //             ),
                                          //             TextSpan(
                                          //               text: '{nama tabungan}',
                                          //               style: TextStyle(fontWeight: FontWeight.bold),
                                          //             ),
                                          //             TextSpan(
                                          //               text: ' ',
                                          //             ),
                                          //             TextSpan(
                                          //               text: '{jumlah uang}',
                                          //               style: TextStyle(fontWeight: FontWeight.bold),
                                          //             ),
                                          //             TextSpan(
                                          //               text: ' dari ',
                                          //             ),
                                          //             TextSpan(
                                          //               text: '{nama akun}',
                                          //               style: TextStyle(fontWeight: FontWeight.bold),
                                          //             ),
                                          //           ],
                                          //         ),
                                          //       ),
                                          //     )
                                          //   ],
                                          // )
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
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(
                          'Lihat',
                          style: TextStyle(
                            fontSize: regular
                          ),
                        ),
                        initiallyExpanded: true,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
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
                                                padding: const EdgeInsets.only(right: 10),
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
                                                padding: const EdgeInsets.only(right: 10),
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
                                    // Container(
                                    //   margin: EdgeInsets.only(top: 20),
                                    //   child: Column(
                                    //     crossAxisAlignment: CrossAxisAlignment.start,
                                    //     children: [
                                    //       Padding(
                                    //         padding: const EdgeInsets.only(bottom: 7.5),
                                    //         child: Text(
                                    //           'Catatan Tabungan',
                                    //           style: TextStyle(
                                    //             fontSize: small,
                                    //             color: greyMinusTwo
                                    //           )
                                    //         ),
                                    //       ),
                                    //       Row(
                                    //         mainAxisAlignment: MainAxisAlignment.start,
                                    //         children: [
                                    //           Padding(
                                    //             padding: const EdgeInsets.only(right: 10),
                                    //             child: Icon(
                                    //               Icons.record_voice_over_outlined,
                                    //               color: greyMinusThree
                                    //             ),
                                    //           ),
                                    //           Text(
                                    //             '"Semua catatan tabungan saya"',
                                    //             style: TextStyle(
                                    //               fontSize: verySmall,
                                    //               color: greyMinusThree
                                    //             )
                                    //           )
                                    //         ],
                                    //       )
                                    //     ],
                                    //   ),
                                    // ),
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
                                                padding: const EdgeInsets.only(right: 10),
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
                                    // Container(
                                    //   margin: EdgeInsets.only(top: 20),
                                    //   child: Column(
                                    //     crossAxisAlignment: CrossAxisAlignment.start,
                                    //     children: [
                                    //       Padding(
                                    //         padding: const EdgeInsets.only(bottom: 7.5),
                                    //         child: Text(
                                    //           'Tagihan Kredit',
                                    //           style: TextStyle(
                                    //             fontSize: small,
                                    //             color: greyMinusTwo
                                    //           )
                                    //         ),
                                    //       ),
                                    //       Row(
                                    //         mainAxisAlignment: MainAxisAlignment.start,
                                    //         children: [
                                    //           Padding(
                                    //             padding: const EdgeInsets.only(right: 10),
                                    //             child: Icon(
                                    //               Icons.record_voice_over_outlined,
                                    //               color: greyMinusThree
                                    //             ),
                                    //           ),
                                    //           Text(
                                    //             '"Semua tagihan kredit saya"',
                                    //             style: TextStyle(
                                    //               fontSize: verySmall,
                                    //               color: greyMinusThree
                                    //             )
                                    //           )
                                    //         ],
                                    //       )
                                    //     ],
                                    //   ),
                                    // ),
                                    Container(
                                      margin: EdgeInsets.only(top: 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 7.5),
                                            child: Text(
                                              'Statistik',
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
                                                padding: const EdgeInsets.only(right: 10),
                                                child: Icon(
                                                  Icons.record_voice_over_outlined,
                                                  color: greyMinusThree
                                                ),
                                              ),
                                              Text(
                                                '"Statistik keuangan saya"',
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
                                              'Wawasan',
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
                                                padding: const EdgeInsets.only(right: 10),
                                                child: Icon(
                                                  Icons.record_voice_over_outlined,
                                                  color: greyMinusThree
                                                ),
                                              ),
                                              Text(
                                                '"Wawasan keuangan saya"',
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
                    onPressed: () async {
                      if(isRecording == true) {
                        await stopRecording();
                      } else  {
                        await startRecording();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      shape: CircleBorder(),
                      side: BorderSide(width: 1, color: mainBlue),
                      padding: EdgeInsets.zero,
                      minimumSize: Size(60, 60),
                      backgroundColor: mainBlue
                    ),
                    child: Icon(
                      isRecording == true ? Icons.square_rounded : Icons.mic_rounded,
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