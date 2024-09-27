import 'package:exinflow/widgets/alert.dart';
import 'package:exinflow/widgets/padding.dart';
import 'package:exinflow/constants/constants.dart';
import 'package:exinflow/services/user.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignInUp extends StatefulWidget {
  final int type;

  SignInUp({Key? key, required this.type}): super(key: key);

  @override
  State<SignInUp> createState() => _SignInUpState();
}

class _SignInUpState extends State<SignInUp> {
  final UserService userService = UserService();

  final formKey = GlobalKey<FormState>();
  final fullName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  List<bool> hidePassword = [true, true];
  final List<Map> types = [
    {
      "sign": "Daftar",
      "question": "Sudah punya akun?",
      "button": "Masuk"
    },
    {
      "sign": "Masuk",
      "question": "Belum punya akun?",
      "button": "Daftar"
    },
  ];

  Future<Map<String, dynamic>> handleEmailSignUp() async {
    if(formKey.currentState?.validate() ?? false) {
      if(password.text.trim() == confirmPassword.text.trim()) {
        Map<String, dynamic> result = await userService.emailSignUp(
          {
            'fullName': fullName.text.trim(),
            'email': email.text.trim(),
            'password': password.text.trim(),
          }
        );

        return result;
      } else {
        return {
            'success': false,
            'message': 'Kata sandi tidak sesuai'
          };
      }
    } else {
        return {
          'success': false,
          'message': 'Data belum diisi'
        };
    }
  }

  Future<Map<String, dynamic>> handleEmailSignIn() async {
    if(formKey.currentState?.validate() ?? false) {
      Map<String, dynamic> result = await userService.emailSignIn(
        {
          'email': email.text.trim(),
          'password': password.text.trim(),
        }
      );

      return result;
    } else {
        return {
          'success': false,
          'message': 'Data belum diisi'
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: AllPadding(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Text(
                            types[widget.type]["sign"],
                            style: TextStyle(
                              fontSize: large,
                              color: mainBluePlusOne,
                              fontFamily: "Open Sans",
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                    
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Form(
                            key: formKey,
                            child: Column(
                              children: [
                                if(widget.type == 0)
                                  // Full Name
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 7.5),
                                          child: Text(
                                            "Nama Lengkap",
                                            style: TextStyle(
                                              color: greyMinusTwo,
                                              fontSize: semiVerySmall,
                                              fontWeight: FontWeight.w500
                                            )
                                          ),
                                        ),
                                        TextFormField(
                                          controller: fullName,
                                          decoration: InputDecoration(
                                            hintText: 'Masukkan nama lengkap',
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.only(left: 7.5),
                                              child: Icon(
                                                Icons.perm_identity_rounded,
                                                color: mainBlue,
                                                size: 22.5,
                                              ),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(vertical: 12.5, horizontal: 25),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(width: 1, color: mainBlueMinusThree),
                                              borderRadius: borderRadius
                                            )
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
                                      ],
                                    ),
                                  ),
                    
                                // Email
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 7.5),
                                        child: Text(
                                          "Email",
                                          style: TextStyle(
                                            color: greyMinusTwo,
                                            fontSize: semiVerySmall
                                          )
                                        ),
                                      ),
                                      TextFormField(
                                        controller: email,
                                        decoration: InputDecoration(
                                          hintText: 'Masukkan email',
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.only(left: 7.5),
                                            child: Icon(
                                              Icons.email_rounded,
                                              color: mainBlue,
                                              size: 22.5,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(vertical: 12.5, horizontal: 25),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(width: 1, color: mainBlueMinusThree),
                                            borderRadius: borderRadius
                                          )
                                        ),
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (value) {
                                          if(value?.isEmpty ?? true) {
                                            return 'Email tidak boleh kosong';
                                          } else if(!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                                            return 'Format email salah';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                    
                                // Password
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 7.5),
                                        child: Text(
                                          "Kata Sandi",
                                          style: TextStyle(
                                            color: greyMinusTwo,
                                            fontSize: semiVerySmall
                                          )
                                        ),
                                      ),
                                      TextFormField(
                                        controller: password,
                                        decoration: InputDecoration(
                                          hintText: 'Masukkan kata sandi',
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.only(left: 7.5),
                                            child: Icon(
                                              Icons.password_rounded,
                                              color: mainBlue,
                                              size: 22.5,
                                            ),
                                          ),
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.only(right: 7.5),
                                            child: IconButton(
                                              icon: Icon(
                                                hidePassword[0] ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                                color: mainBlue,
                                                size: 22.5,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  hidePassword[0] = !hidePassword[0];
                                                });
                                              }
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(vertical: 12.5, horizontal: 25),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(width: 1, color: mainBlueMinusThree),
                                            borderRadius: borderRadius
                                          )
                                        ),
                                        keyboardType: TextInputType.text,
                                        obscureText: hidePassword[0],
                                        validator: (value) {
                                          if(value?.isEmpty ?? true) {
                                            return 'Kata sandi tidak boleh kosong';
                                          } else if (value!.length < 8) {
                                            return 'Kata sandi minimal 8 karakter';
                                          } else if (value.length > 24) {
                                            return 'Kata sandi maksimal 24 karakter';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                    
                                if(widget.type == 0)
                                  // Confirm Password
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 7.5),
                                          child: Text(
                                            "Konfirmasi Kata Sandi",
                                            style: TextStyle(
                                              color: greyMinusTwo,
                                              fontSize: semiVerySmall
                                            )
                                          ),
                                        ),
                                        TextFormField(
                                          controller: confirmPassword,
                                          decoration: InputDecoration(
                                            hintText: 'Masukkan ulang kata sandi',
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.only(left: 7.5),
                                              child: Icon(
                                                Icons.lock_rounded,
                                                color: mainBlue,
                                                size: 22.5,
                                              ),
                                            ),
                                            suffixIcon: Padding(
                                              padding: const EdgeInsets.only(right: 7.5),
                                              child: IconButton(
                                                icon: Icon(
                                                  hidePassword[1] ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                                  color: mainBlue,
                                                  size: 22.5,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    hidePassword[1] = !hidePassword[1];
                                                  });
                                                }
                                              ),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(vertical: 12.5, horizontal: 25),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(width: 1, color: mainBlueMinusThree),
                                              borderRadius: borderRadius
                                            )
                                          ),
                                          keyboardType: TextInputType.text,
                                          obscureText: hidePassword[1],
                                          validator: (value) {
                                            if(value != password.text) {
                                              return 'Kata sandi tidak sesuai';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                    
                                // Submit
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: mainBlue,
                                        padding: EdgeInsets.symmetric(vertical: 12.5, horizontal: 25)
                                      ),
                                      child: Text(
                                        types[widget.type]["sign"],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: semiVerySmall,
                                          fontWeight: FontWeight.w500
                                        ),
                                      ),
                                      onPressed: () async {
                                        Map<String, dynamic> result = widget.type == 0 ? await handleEmailSignUp() : await handleEmailSignIn();

                                        Alert.show(context, result, {});

                                        if(result['success'] == true) {
                                          context.go('/home');
                                        }
                                      }
                                    ),
                                  ),
                                )
                              ]
                            )
                          ),
                        ),
                    
                        // Container(
                        //   child: Column(
                        //     children: [
                        //       Padding(
                        //         padding: const EdgeInsets.only(bottom: 10),
                        //         child: Text(
                        //           "Atau",
                        //           style: TextStyle(
                        //             color: greyMinusOne,
                        //             fontSize: semiVerySmall
                        //           ),
                        //         ),
                        //       ),

                        //       Padding(
                        //         padding: const EdgeInsets.only(top: 10),
                        //         child: SizedBox(
                        //           width: double.infinity,
                        //           child: ElevatedButton(
                        //             style: ElevatedButton.styleFrom(
                        //               backgroundColor: Colors.white,
                        //               padding: EdgeInsets.symmetric(vertical: 15)
                        //             ),
                        //             child: Row(
                        //               mainAxisAlignment: MainAxisAlignment.center,
                        //               children: [
                        //                 Padding(
                        //                   padding: const EdgeInsets.only(right: 12.5),
                        //                   child: Image.asset(
                        //                     'assets/images/icon/google.png',
                        //                     width: 22.5,
                        //                     height: 22.5
                        //                   ),
                        //                 ),
                        //                 Text(
                        //                   '${types[widget.type]["sign"]} dengan Google',
                        //                   style: TextStyle(
                        //                     color: greyMinusTwo,
                        //                     fontSize: semiVerySmall,
                        //                     fontWeight: FontWeight.w500
                        //                   ),
                        //                 )
                        //               ],
                        //             ),
                        //             onPressed: () async {
                        //               Map<String, dynamic> result = await userService.googleSignUp(email.text.trim());

                        //               Alert.show(context, result);

                        //               if(result['success'] == true) {
                        //                 context.go('/home');
                        //               }
                        //             }
                        //           ),
                        //         ),
                        //       ),
                        //     ]
                        //   )
                        // )
                      ],
                    ),
                  ),
                ),
              ),

              AllPadding(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      color: mainBlueMinusThree,
                      borderRadius: borderRadius,
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
                          spreadRadius: 20,
                          blurRadius: 20,
                          offset: Offset(0, 3),
                        ),
                      ]
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 25, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            types[widget.type]["question"],
                            style: TextStyle(
                              color: greyPlusOne,
                              fontSize: verySmall
                            ),
                          ),
                          
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              side: BorderSide(color: mainBluePlusOne)
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 5),
                                  child: Text(
                                    types[widget.type]["button"],
                                    style: TextStyle(
                                      color: mainBluePlusOne,
                                      fontSize: semiVerySmall
                                    )
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_outward_rounded,
                                  color: mainBluePlusOne,
                                  size: 25,
                                )
                              ],
                            ),
                            onPressed: () {
                              if(widget.type == 0) {
                                context.go('/signinup?type=1');
                              } else if(widget.type == 1) {
                                context.go('/signinup?type=0');
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ]
          ),
        ),
      )
    );
  }
}