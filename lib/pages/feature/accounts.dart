import 'package:exinflow/widgets/alert.dart';
import 'package:exinflow/widgets/padding.dart';
import 'package:flutter/material.dart';
import 'package:exinflow/widgets/top_bar.dart';
import 'package:exinflow/constants/constants.dart';
import 'package:exinflow/constants/data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:exinflow/services/account.dart';
import 'package:exinflow/controllers/account.dart';
import 'package:exinflow/models/account.dart';

// List
class Accounts extends StatefulWidget {
  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  final user = FirebaseAuth.instance.currentUser;
  final AccountService accountService = AccountService();
  final AccountController accountController = Get.find<AccountController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        id: '',
        title: "Akun",
        menu: "Akun",
        page: "All",
        type: '',
        from: '',
        subtype: '',
        subIndex: -1
      ),

      body: SingleChildScrollView(
        child: AllPadding(
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Accounts').where('User', isEqualTo: user?.uid ?? '').where('Is_Deleted', isEqualTo: false).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Error");
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Text('');
                  }
                
                  accountController.setLength(snapshot.data!.docs.length);
                  
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var filteredDocs = snapshot.data!.docs.toList();
                      var doc = filteredDocs[index];
                
                      return InkWell(
                        onTap: () {
                          accountController.setAccount(
                            AccountModel(
                              id: doc.id,
                              name: doc['Name'],
                              amount: doc['Amount'].toDouble(),
                              currency: doc['Currency'],
                              icon: doc['Icon'],
                              color: doc['Color'].toString(),
                            )
                          );
                          context.push('/manage/accounts/account/${doc.id}?action=view');
                        },
                        child: Container(
                          padding: EdgeInsets.all(15),
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
                
                                                    accountController.setAccount(
                                                      AccountModel(
                                                        id: doc.id,
                                                        name: doc['Name'],
                                                        amount: doc['Amount'].toDouble(),
                                                        currency: doc['Currency'],
                                                        icon: doc['Icon'],
                                                        color: doc['Color'].toString(),
                                                      )
                                                    );
                
                                                    context.push('/manage/accounts/account/${doc.id}?action=edit&from=dots');
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
                                                      
                                                        Map<String, dynamic> result = await accountService.deleteAccount(user?.uid ?? '', doc.id);
                
                                                        accountController.setAccount(
                                                          AccountModel(
                                                            id: '',
                                                            name: '',
                                                            amount: 0,
                                                            currency: '',
                                                            icon: '',
                                                            color: '',
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
                                "${currencies.firstWhere((currency) => currency["ISO_Code"] == doc['Currency'])['Symbol'] ?? ''}${NumberFormat('#,##0.###', 'de_DE').format(doc['Amount'])}",
                                style: TextStyle(
                                  fontSize: small,
                                  color: greyMinusTwo
                                )
                              ),
                            ]
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}