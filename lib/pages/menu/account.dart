import 'package:exinflow/widgets/alert.dart';
import 'package:exinflow/widgets/padding.dart';
import 'package:exinflow/constants/constants.dart';
import 'package:exinflow/constants/data.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:exinflow/controllers/user.dart';
import 'package:exinflow/models/user.dart';
import 'package:get/get.dart';
import 'package:exinflow/services/user.dart';

class Account extends StatefulWidget {
  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  bool isEdit = false;
  final FirebaseAuth authentication = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;
  final UserService userService = UserService();
  final UserController userController = Get.find<UserController>();
  String selectedCurrency = '';
  String changedName = '';

  Future<Map<String, dynamic>> signOut() async {
    try {
      await authentication.signOut();

      User? checkUser = authentication.currentUser;

      if(checkUser == null) {
        userController.setUser(
          UserModel(
            uid: '',
            email: '',
            fullName: '',
            mainCurrency: ''
          )
        );

        return {
          'success': true,
          'message': 'Sukses keluar dari akun'
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal keluar dari akun'
        };
      }
    } on FirebaseAuthException catch(e) {
      return {
        'success': false,
        'message': e.toString()
      };
    }
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
                const Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Text(
                    "Akun",
                    style: TextStyle(
                      fontSize: large,
                      color: mainBluePlusOne,
                      fontFamily: "Open Sans",
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),

                Container(
                  padding: EdgeInsets.only(right: 15, left: 15, top: 15, bottom: 45),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/hero/account.png"),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: borderRadius
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Start Edit
                            if(isEdit == false)
                              Container(
                                width: 41,
                                height: 41,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: IconButton(
                                    padding: EdgeInsets.all(5),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.white,
                                      size: 22.5
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isEdit = !isEdit;
                                      });
                                    },
                                  ),
                                ),
                              ),
                        
                            // Cancel Edit
                            if(isEdit == true)
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Container(
                                  width: 41,
                                  height: 41,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      padding: EdgeInsets.all(5),
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 30
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          changedName = '';
                                          selectedCurrency = '';
                                          isEdit = !isEdit;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                        
                            // Save Edit
                            if(isEdit == true)
                              Container(
                                width: 41,
                                height: 41,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: IconButton(
                                    padding: EdgeInsets.all(5),
                                    icon: const Icon(
                                      Icons.done_rounded,
                                      color: Colors.white,
                                      size: 30
                                    ),
                                    onPressed: () async {
                                      if(changedName != '' || selectedCurrency != '') {
                                        Map<String, dynamic> nameResult = {};
                                        Map<String, dynamic> currencyResult = {};
                                        if(changedName != '') {
                                          nameResult = await userService.modifyName(user?.uid ?? '', changedName);
                                        }
                                        if(selectedCurrency != '') {
                                          currencyResult = await userService.modifyMainCurrency(user?.uid ?? '', selectedCurrency);
                                        }

                                        setState(() {
                                          changedName = '';
                                          selectedCurrency = '';
                                          isEdit = !isEdit;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      if(isEdit == true)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TextFormField(
                            initialValue: userController.user?.fullName ?? '',
                            onChanged: (value) {
                              setState(() {
                                changedName = value;
                              });
                            },
                            enabled: isEdit,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(width: 1, color: Colors.white),
                                borderRadius: borderRadius
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1, color: Colors.white),
                                borderRadius: borderRadius
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1, color: Colors.white),
                                borderRadius: borderRadius
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1, color: Colors.white),
                                borderRadius: borderRadius
                              ),
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: regular
                            ),
                            keyboardType: TextInputType.name,
                            validator: (value) {
                              if(value?.isEmpty ?? true) {
                                return 'Nama lengkap tidak boleh kosong';
                              } else if (value!.length < 3) {
                                return 'Nama lengkap minimal 3 karakter';
                              } else if (value.length > 50) {
                                return 'Nama lengkap maksimal 50 karakter';
                              }
                              return null;
                            },
                          ),
                        ),
                      if(isEdit != true)
                        Text(
                          userController.user?.fullName ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: semiMedium
                          ),
                        ),

                      Text(
                        userController.user?.email ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: verySmall
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text(
                                "Mata Uang Utama",
                                style: TextStyle(
                                  color: Colors.white
                                ),
                              ),
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.white, width: 1),
                                borderRadius: borderRadius,
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.5, vertical: isEdit == true ? 0 : 7.5),
                                child: isEdit == true ? DropdownButtonHideUnderline(
                                  child: SizedBox(
                                    height: 35,
                                    child: DropdownButton<String>(
                                      value: selectedCurrency == '' ? userController.user?.mainCurrency : selectedCurrency,
                                      items: currencies.map((currency) {
                                        return DropdownMenuItem(
                                          value: currency['ISO_Code'],
                                          child: Text(
                                            currency['ISO_Code'] ?? '',
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: isEdit ? (value) {
                                        setState(() {
                                          selectedCurrency = value ?? '';
                                        });
                                      } : null,
                                      style: TextStyle(color: greyMinusOne, fontSize: tiny),
                                      iconDisabledColor: Colors.transparent,
                                      iconEnabledColor: greyMinusOne,
                                    ),
                                  ),
                                ) : Text(
                                  userController.user?.mainCurrency ?? '',
                                  style: TextStyle(
                                    color: greyMinusOne,
                                    fontSize: tiny
                                  )
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ]
                  )
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainBlue,
                        padding: EdgeInsets.symmetric(vertical: 12.5, horizontal: 25)
                      ),
                      child: Text(
                        'Keluar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: semiVerySmall,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      onPressed: () async {
                        bool confirm = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Keluar',
                                style: TextStyle(
                                  fontFamily: "Open Sans",
                                  fontWeight: FontWeight.w500,
                                  color: greyMinusTwo
                                )
                              ),
                              content: Text(
                                'Apakah Anda yakin ingin keluar?',
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
                          Map<String, dynamic> result = await signOut();
                  
                          Alert.show(context, result, {});
                    
                          if(result['success'] == true) {
                            context.go('/signinup?type=1');
                          }
                        }
                      }
                    ),
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