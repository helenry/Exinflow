import 'package:exinflow/constants/constants.dart';
import 'package:exinflow/constants/data.dart';
import 'package:exinflow/widgets/alert.dart';
import 'package:exinflow/widgets/padding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:exinflow/controllers/user.dart';
import 'package:exinflow/controllers/currency.dart';
import 'package:exinflow/controllers/transaction.dart';
import 'package:exinflow/controllers/category.dart';
import 'package:exinflow/controllers/account.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'package:exinflow/services/user.dart';
import 'package:exinflow/services/account.dart';
import 'package:exinflow/services/category.dart';
import 'package:exinflow/services/currency.dart';
import 'package:exinflow/models/transaction.dart';
import 'package:exinflow/models/common.dart';
import 'package:exinflow/models/account.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser;
  final UserService userService = UserService();
  final AccountService accountService = AccountService();
  final CategoryService categoryService = CategoryService();
  final UserController userController = Get.find<UserController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final AccountController accountController = Get.find<AccountController>();
  final TransactionController transactionController = Get.find<TransactionController>();
  String selectedCurrency = 'IDR';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(userController.user?.mainCurrency == '') {
        selectMainCurrency(context);
      }
    });
  }

  Future<Map<String, dynamic>> handleInitializeUser(String currency) async {
    Map<String, dynamic> currencyResult = await userService.modifyMainCurrency(user?.uid ?? '', currency);
    Map<String, dynamic> accountResult = await accountService.createAccount(
      user?.uid ?? '',
      true,
      AccountModel(
        id: '',
        name: 'Tunai',
        amount: 0,
        currency: userController.user?.mainCurrency ?? '',
        icon: 'account_balance_wallet_outlined',
        color: '0f677b',
        isDeleted: false
      )
    );
    Map<String, dynamic> categoriesResult = await categoryService.createStarters(user?.uid ?? '');

    if(currencyResult['success'] == true && accountResult['success'] == true && categoriesResult['success'] == true) {
      return currencyResult;
    } else {
      print({
        'success': false,
        'message': 'Gagal mengubah mata uang utama'
      });
      return {
        'success': false,
        'message': 'Gagal mengubah mata uang utama'
      };
    }
  }

  Future<void> selectMainCurrency(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Dialog(
                insetPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 300),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          'Pilih Mata Uang Utama',
                          style: TextStyle(
                            fontFamily: "Open Sans",
                            fontWeight: FontWeight.w500,
                            fontSize: medium,
                            color: greyMinusTwo
                          )
                        ),
                      ),
                  
                      Container(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: greyMinusTwo, width: 1),
                            borderRadius: borderRadius,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: DropdownButtonHideUnderline(
                              child: SizedBox(
                                height: 35,
                                child: DropdownButton<String>(
                                  value: selectedCurrency,
                                  items: currencies.map((currency) {
                                    return DropdownMenuItem(
                                      value: currency['ISO_Code'],
                                      child: Text(currency['Name_ID'] ?? ''),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCurrency = value ?? '';
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainBlue,
                              padding: EdgeInsets.symmetric(vertical: 12.5, horizontal: 25)
                            ),
                            child: Text(
                              'Simpan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: semiVerySmall,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                            onPressed: () async {
                              Map<String, dynamic> result = await handleInitializeUser(selectedCurrency);                                            
                              if(result['success'] == true) {
                                Navigator.of(context).pop();
                              }
                            }
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
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
                Hero(userController: userController, user: user),
                Activities(user: user, transactionController: transactionController, categoryController: categoryController, accountController: accountController, userController: userController),
              ],
            ),
          )
        ),
      ),
    );
  }
}

// Hero
class Hero extends StatelessWidget {
  UserController userController;
  dynamic user;

  Hero({Key? key, required this.userController,  required this.user}): super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now().toUtc().add(Duration(hours: 7));
    String monthYear = DateFormat.yMMMM('id_ID').format(now);
    final CurrencyService currencyService = CurrencyService();
    final CurrencyController currencyController = Get.find<CurrencyController>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                'Halo, ${userController.user?.fullName.split(' ').first ?? ''}',
                style: TextStyle(
                  fontSize: medium,
                  fontFamily: "Open Sans",
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(12.5),
              decoration: BoxDecoration(
                color: greyMinusFive,
                borderRadius: borderRadius
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(
                      fontSize: regular,
                      color: mainBlue,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      children: [
                        Text(
                          userController.user?.mainCurrency == '' ? '' : currencies.firstWhere((currency) => currency["ISO_Code"] == userController.user?.mainCurrency)['Symbol'] ?? '',
                          style: TextStyle(
                            color: mainBlueMinusOne,
                            fontSize: medium
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
                                      color: mainBlue,
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

                                return Text(
                                  NumberFormat('#,##0.###', 'de_DE').format(total),
                                  style: TextStyle(
                                    color: mainBlue,
                                    fontSize: semiLarge
                                  )
                                );
                              }
                            );
                          },
                        )
                      ],
                    ),
                  ),
      
                  Text(
                    monthYear,
                    style: TextStyle(
                      fontSize: semiVerySmall,
                      color: greyMinusTwo,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25, top: 10),
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
                                      userController.user?.mainCurrency == '' ? '' : currencies.firstWhere((currency) => currency["ISO_Code"] == userController.user?.mainCurrency)['Symbol'] ?? '',
                                      style: TextStyle(
                                        color: greyMinusTwo
                                      ),
                                    ),
                                    Text(
                                      NumberFormat('#,##0.###', 'de_DE').format(230000),
                                      style: TextStyle(
                                        fontSize: tiny
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
                                      userController.user?.mainCurrency == '' ? '' : currencies.firstWhere((currency) => currency["ISO_Code"] == userController.user?.mainCurrency)['Symbol'] ?? '',
                                      style: TextStyle(
                                        color: greyMinusTwo
                                      ),
                                    ),
                                    Text(
                                      NumberFormat('#,##0.###', 'de_DE').format(452000),
                                      style: TextStyle(
                                        fontSize: tiny
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
                  ),
      
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 17.5, vertical: 12.5),
                          side: const BorderSide(width: 1.0, color: mainBlue),
                          backgroundColor: Colors.white
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Transform.rotate(
                                angle: 180 * pi / 180,
                                child: const Icon(
                                  Icons.file_download_outlined,
                                  size: 20
                                ),
                              ),
                            ),
                            const Text(
                              "Keluar"
                            )
                          ],
                        ),
                        onPressed: () {
      
                        },
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 17.5, vertical: 12.5),
                          side: const BorderSide(width: 1.0, color: mainBlue),
                          backgroundColor: Colors.white
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.file_download_outlined,
                                size: 20
                              ),
                            ),
                            Text(
                              "Masuk"
                            )
                          ],
                        ),
                        onPressed: () {
      
                        },
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 17.5, vertical: 12.5),
                          side: const BorderSide(width: 1.0, color: mainBlue),
                          backgroundColor: Colors.white
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Image.asset(
                                'assets/images/icon/transfer.png',
                                width: 17.5,
                                height: 17.5
                              ),
                            ),
                            const Text(
                              "Transfer"
                            )
                          ],
                        ),
                        onPressed: () {
      
                        },
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        )
      ),
    );
  }
}

// Activities
class Activities extends StatelessWidget {
  TransactionController transactionController;
  CategoryController categoryController;
  AccountController accountController;
  UserController userController;
  dynamic user;

  Activities({Key? key, required this.transactionController, required this.categoryController, required this.accountController, required this.userController, required this.user}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            "Aktivitas",
            style: TextStyle(
              fontSize: semiMedium,
              fontWeight: FontWeight.w500,
              color: greyMinusOne,
              fontFamily: "Open Sans"
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaksi
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Container(
                  width: 335,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(
                    color: mainBlueMinusFour,
                    borderRadius: borderRadius
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Transaksi",
                              style: TextStyle(
                                fontSize: small,
                                color: mainBlue,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Container(
                                    width: 41,
                                    height: 41,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: greyMinusTwo, width: 1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: IconButton(
                                        padding: EdgeInsets.all(5),
                                        icon: const Icon(
                                          Icons.add_rounded,
                                          color: greyMinusTwo,
                                          size: 30
                                        ),
                                        onPressed: () {
                                          
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 41,
                                  height: 41,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: greyMinusTwo, width: 1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      padding: EdgeInsets.all(5),
                                      icon: const Icon(
                                        Icons.arrow_outward_rounded,
                                        color: greyMinusTwo,
                                        size: 30
                                      ),
                                      onPressed: () {
                                        context.push('/manage/transactions');
                                      },
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),

                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('Transactions').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).orderBy('Created_At', descending: true).limit(5).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Container(height: 125, child: Center(child: Text("Error")));
                          }
                          if (!snapshot.hasData || snapshot.data == null) {
                            return Container(height: 125, child: Center(child: Text('Belum ada transaksi')));
                          }
                      
                          var docs = snapshot.data!.docs;
                      
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var doc = docs[index];

                              return InkWell(
                                onTap: () async {
                                  transactionController.setTransaction(
                                    TransactionModel(
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
                                      date: doc['Date'],
                                    )
                                  );
                                  context.push('/manage/transactions/transaction/${doc.id}?action=view');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            margin: EdgeInsets.only(right: 15),
                                            decoration: BoxDecoration(
                                              borderRadius: borderRadius,
                                              color: Color(int.parse('FF${doc['Category'] != null ? doc['Category']['Sub_Id'] != null ? categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).color : categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).color : '0f667b'}', radix: 16))
                                            ),
                                            child: Icon(
                                              doc['Category'] != null ? icons[doc['Category']['Sub_Id'] != null ? categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).subs![doc['Category']['Sub_Id']].icon : categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).icon] : Icons.loop_rounded,
                                              color: Colors.white,
                                              size: 22.5
                                            )
                                          ),
                              
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                doc['Category'] != null ?
                                                  doc['Category']['Sub_Id'] != null ?
                                                    categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).subs![doc['Category']['Sub_Id']].name :
                                                    categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).name :
                                                  'Transfer',
                                                style: TextStyle(
                                                  fontSize: verySmall
                                                )
                                              ),
                                          
                                              Text(
                                                doc['Account_Id']['Source'] != null && doc['Account_Id']['Destination'] != null ? '${accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Source']).name} > ${accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Destination']).name}' : doc['Account_Id']['Source'] == null ? accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Destination']).name : accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Source']).name,
                                                style: TextStyle(
                                                  fontSize: tiny,
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
                                            userController.user?.mainCurrency == '' ? '' :
                                            doc['Account_Id']['Source'] == null ?
                                              currencies.firstWhere((currency) => currency['ISO_Code'] == accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Destination']).currency)['Symbol'] ?? '' :
                                              currencies.firstWhere((currency) => currency['ISO_Code'] == accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Source']).currency)['Symbol'] ?? '',
                                            style: TextStyle(
                                              fontSize: tiny,
                                              fontWeight: FontWeight.w500,
                                              color: doc['Type_Id'] == 0 ? redPlusOne : doc['Type_Id'] == 1 ? greenPlusOne : mainBlue
                                            )
                                          ),
                                          Text(
                                            NumberFormat('#,##0.###', 'de_DE').format(doc['Amount']),
                                            style: TextStyle(
                                              fontSize: tiny,
                                              fontWeight: FontWeight.w500,
                                              color: doc['Type_Id'] == 0 ? redPlusOne : doc['Type_Id'] == 1 ? greenPlusOne : mainBlue
                                            )
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                )
                              );
                            }
                          );
                        }
                      )
                    ],
                  ),
                ),
              ),
              
              // // Templat Transaksi
              // Padding(
              //   padding: const EdgeInsets.only(right: 15),
              //   child: Container(
              //     width: 335,
              //     padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              //     decoration: BoxDecoration(
              //       color: mainBlueMinusFour,
              //       borderRadius: borderRadius
              //     ),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Padding(
              //           padding: EdgeInsets.only(bottom: 15),
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               const Text(
              //                 "Templat Transaksi",
              //                 style: TextStyle(
              //                   fontSize: small,
              //                   color: mainBlue,
              //                   fontWeight: FontWeight.w500
              //                 ),
              //               ),
              //               Row(
              //                 children: [
              //                   Padding(
              //                     padding: const EdgeInsets.only(right: 5),
              //                     child: Container(
              //                       width: 41,
              //                       height: 41,
              //                       decoration: BoxDecoration(
              //                         border: Border.all(color: greyMinusTwo, width: 1),
              //                         shape: BoxShape.circle,
              //                       ),
              //                       child: Center(
              //                         child: IconButton(
              //                           padding: EdgeInsets.all(5),
              //                           icon: const Icon(
              //                             Icons.add_rounded,
              //                             color: greyMinusTwo,
              //                             size: 30
              //                           ),
              //                           onPressed: () {
                                          
              //                           },
              //                         ),
              //                       ),
              //                     ),
              //                   ),
              //                   Container(
              //                     width: 41,
              //                     height: 41,
              //                     decoration: BoxDecoration(
              //                       border: Border.all(color: greyMinusTwo, width: 1),
              //                       shape: BoxShape.circle,
              //                     ),
              //                     child: Center(
              //                       child: IconButton(
              //                         padding: EdgeInsets.all(5),
              //                         icon: const Icon(
              //                           Icons.arrow_outward_rounded,
              //                           color: greyMinusTwo,
              //                           size: 30
              //                         ),
              //                         onPressed: () {

              //                         },
              //                       ),
              //                     ),
              //                   )
              //                 ],
              //               )
              //             ],
              //           )
              //         ),

              //         StreamBuilder<QuerySnapshot>(
              //           stream: FirebaseFirestore.instance.collection('Transaction_Templates').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).orderBy('Created_At', descending: true).limit(5).snapshots(),
              //           builder: (context, snapshot) {
              //             if (snapshot.hasError) {
              //               return Container(height: 125, child: Center(child: Text("Error")));
              //             }
              //             if (!snapshot.hasData || snapshot.data == null) {
              //               return Container(height: 125, child: Center(child: Text('Belum ada templat transaksi')));
              //             }
                      
              //             var docs = snapshot.data!.docs;

              //             return ListView.builder(
              //               shrinkWrap: true,
              //               physics: NeverScrollableScrollPhysics(),
              //               itemCount: snapshot.data!.docs.length,
              //               itemBuilder: (context, index) {
              //                 var doc = snapshot.data!.docs[index];

              //                 return InkWell(
              //                   onTap: () async {
              //                     transactionController.setTransactionTemplate(
              //                       TransactionTemplateModel(
              //                         id: doc.id,
              //                         amount: doc['Amount'].toDouble(),
              //                         category: Category(
              //                           id: doc['Category']['Id'],
              //                           subId: doc['Category']['Sub_Id']
              //                         ),
              //                         accountId: Account(
              //                           destination: doc['Account_Id']['Destination'],
              //                           source: doc['Account_Id']['Source']
              //                         ),
              //                         typeId: doc['Type_Id'],
              //                         fee: doc['Fee'],
              //                         note: doc['Note'],
              //                         name: doc['Name'],
              //                       )
              //                     );
              //                     context.push('/manage/transactions/template/${doc.id}?action=view');
              //                   },
              //                   child: Padding(
              //                     padding: const EdgeInsets.only(bottom: 10),
              //                     child: Row(
              //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                       children: [
              //                         Row(
              //                           children: [
              //                             Container(
              //                               width: 40,
              //                               height: 40,
              //                               margin: EdgeInsets.only(right: 15),
              //                               decoration: BoxDecoration(
              //                                 borderRadius: borderRadius,
              //                                 color: Color(int.parse('FF${doc['Category'] != null ? doc['Category']['Sub_Id'] != null ? categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).color : categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).color : '0f667b'}', radix: 16))
              //                               ),
              //                               child: Icon(
              //                                 doc['Category'] != null ? icons[doc['Category']['Sub_Id'] != null ? categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).subs![doc['Category']['Sub_Id']].icon : categoryController.categories.value.firstWhere((category) => category.id == doc['Category']['Id']).icon] : Icons.loop_rounded,
              //                                 color: Colors.white,
              //                                 size: 22.5
              //                               )
              //                             ),
                              
              //                             Column(
              //                               crossAxisAlignment: CrossAxisAlignment.start,
              //                               children: [
              //                                 Text(
              //                                   doc['Name'],
              //                                   style: TextStyle(
              //                                     fontSize: verySmall
              //                                   )
              //                                 ),
                                          
              //                                 Text(
              //                                   doc['Account_Id']['Source'] != null && doc['Account_Id']['Destination'] != null ? '${accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Source']).name} > ${accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Destination']).name}' : doc['Account_Id']['Source'] == null ? accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Destination']).name : accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Source']).name,
              //                                   style: TextStyle(
              //                                     fontSize: tiny,
              //                                     color: greyMinusThree
              //                                   )
              //                                 )
              //                               ],
              //                             ),
              //                           ],
              //                         ),
                              
              //                         Row(
              //                           children: [
              //                            Text(
              //                              userController.user?.mainCurrency == '' ? '' :
              //                               doc['Account_Id']['Source'] == null ? currencies.firstWhere((currency) => currency['ISO_Code'] == accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Destination']).currency)['Symbol'] ?? '' : currencies.firstWhere((currency) => currency['ISO_Code'] == accountController.accounts.value.firstWhere((account) => account.id == doc['Account_Id']['Source']).currency)['Symbol'] ?? '',
              //                               style: TextStyle(
              //                                 fontSize: tiny,
              //                                 fontWeight: FontWeight.w500,
              //                                 color: doc['Type_Id'] == 0 ? redPlusOne : doc['Type_Id'] == 1 ? greenPlusOne : mainBlue
              //                               )
              //                             ),
              //                             Text(
              //                               NumberFormat('#,##0.###', 'de_DE').format(doc['Amount']),
              //                               style: TextStyle(
              //                                 fontSize: tiny,
              //                                 fontWeight: FontWeight.w500,
              //                                 color: doc['Type_Id'] == 0 ? redPlusOne : doc['Type_Id'] == 1 ? greenPlusOne : mainBlue
              //                               )
              //                             ),
              //                           ],
              //                         ),
              //                       ],
              //                     )
              //                   )
              //                 );
              //               }
              //             );
              //           }
              //         )
              //       ],
              //     ),
              //   ),
              // ),
              
              // Catatan Tabungan
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Container(
                  width: 335,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(
                    color: mainBlueMinusFour,
                    borderRadius: borderRadius
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Catatan Tabungan",
                            style: TextStyle(
                              fontSize: small,
                              color: mainBlue,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Container(
                                  width: 41,
                                  height: 41,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: greyMinusTwo, width: 1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      padding: EdgeInsets.all(5),
                                      icon: const Icon(
                                        Icons.add_rounded,
                                        color: greyMinusTwo,
                                        size: 30
                                      ),
                                      onPressed: () {
                                        
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 41,
                                height: 41,
                                decoration: BoxDecoration(
                                  border: Border.all(color: greyMinusTwo, width: 1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: IconButton(
                                    padding: EdgeInsets.all(5),
                                    icon: const Icon(
                                      Icons.arrow_outward_rounded,
                                      color: greyMinusTwo,
                                      size: 30
                                    ),
                                    onPressed: () {
                                      
                                    },
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),

                      Container(
                        height: 125,
                        child: const Center(
                          child: Text(
                            "Belum ada catatan tabungan",
                            style: TextStyle(
                              fontSize: tiny,
                              color: greyMinusTwo
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              
              // Tabungan
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Container(
                  width: 335,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(
                    color: mainBlueMinusFour,
                    borderRadius: borderRadius
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tabungan",
                            style: TextStyle(
                              fontSize: small,
                              color: mainBlue,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Container(
                                  width: 41,
                                  height: 41,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: greyMinusTwo, width: 1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      padding: EdgeInsets.all(5),
                                      icon: const Icon(
                                        Icons.add_rounded,
                                        color: greyMinusTwo,
                                        size: 30
                                      ),
                                      onPressed: () {
                                        
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 41,
                                height: 41,
                                decoration: BoxDecoration(
                                  border: Border.all(color: greyMinusTwo, width: 1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: IconButton(
                                    padding: EdgeInsets.all(5),
                                    icon: const Icon(
                                      Icons.arrow_outward_rounded,
                                      color: greyMinusTwo,
                                      size: 30
                                    ),
                                    onPressed: () {
                                      
                                    },
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),

                      Container(
                        height: 125,
                        child: const Center(
                          child: Text(
                            "Belum ada tabungan",
                            style: TextStyle(
                              fontSize: tiny,
                              color: greyMinusTwo
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              
              // // Anggaran
              // Padding(
              //   padding: const EdgeInsets.only(right: 15),
              //   child: Container(
              //     width: 335,
              //     padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              //     decoration: BoxDecoration(
              //       color: mainBlueMinusFour,
              //       borderRadius: borderRadius
              //     ),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             const Text(
              //               "Anggaran",
              //               style: TextStyle(
              //                 fontSize: small,
              //                 color: mainBlue,
              //                 fontWeight: FontWeight.w500
              //               ),
              //             ),
              //             Row(
              //               children: [
              //                 Padding(
              //                   padding: const EdgeInsets.only(right: 5),
              //                   child: Container(
              //                     width: 41,
              //                     height: 41,
              //                     decoration: BoxDecoration(
              //                       border: Border.all(color: greyMinusTwo, width: 1),
              //                       shape: BoxShape.circle,
              //                     ),
              //                     child: Center(
              //                       child: IconButton(
              //                         padding: EdgeInsets.all(5),
              //                         icon: const Icon(
              //                           Icons.add_rounded,
              //                           color: greyMinusTwo,
              //                           size: 30
              //                         ),
              //                         onPressed: () {
                                        
              //                         },
              //                       ),
              //                     ),
              //                   ),
              //                 ),
              //                 Container(
              //                   width: 41,
              //                   height: 41,
              //                   decoration: BoxDecoration(
              //                     border: Border.all(color: greyMinusTwo, width: 1),
              //                     shape: BoxShape.circle,
              //                   ),
              //                   child: Center(
              //                     child: IconButton(
              //                       padding: EdgeInsets.all(5),
              //                       icon: const Icon(
              //                         Icons.arrow_outward_rounded,
              //                         color: greyMinusTwo,
              //                         size: 30
              //                       ),
              //                       onPressed: () {
                                      
              //                       },
              //                     ),
              //                   ),
              //                 )
              //               ],
              //             )
              //           ],
              //         ),

              //         Container(
              //           height: 125,
              //           child: const Center(
              //             child: Text(
              //               "Belum ada anggaran",
              //               style: TextStyle(
              //                 fontSize: tiny,
              //                 color: greyMinusTwo
              //               ),
              //             ),
              //           ),
              //         )
              //       ],
              //     ),
              //   ),
              // ),
              
              // Kredit
              Container(
                width: 335,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  color: mainBlueMinusFour,
                  borderRadius: borderRadius
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Kredit",
                          style: TextStyle(
                            fontSize: small,
                            color: mainBlue,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Container(
                                width: 41,
                                height: 41,
                                decoration: BoxDecoration(
                                  border: Border.all(color: greyMinusTwo, width: 1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: IconButton(
                                    padding: EdgeInsets.all(5),
                                    icon: const Icon(
                                      Icons.add_rounded,
                                      color: greyMinusTwo,
                                      size: 30
                                    ),
                                    onPressed: () {
                                      
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 41,
                              height: 41,
                              decoration: BoxDecoration(
                                border: Border.all(color: greyMinusTwo, width: 1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: IconButton(
                                  padding: EdgeInsets.all(5),
                                  icon: const Icon(
                                    Icons.arrow_outward_rounded,
                                    color: greyMinusTwo,
                                    size: 30
                                  ),
                                  onPressed: () {
                                    
                                  },
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
              
                    Container(
                      height: 125,
                      child: const Center(
                        child: Text(
                          "Belum ada kredit",
                          style: TextStyle(
                            fontSize: tiny,
                            color: greyMinusTwo
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          )
        )
      ],
    );
  }
}