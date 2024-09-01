import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:exinflow/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exinflow/widgets/alert.dart';

import 'package:exinflow/controllers/account.dart';
import 'package:exinflow/controllers/category.dart';
import 'package:exinflow/controllers/icon.dart';
import 'package:exinflow/controllers/color.dart';

import 'package:exinflow/services/account.dart';
import 'package:exinflow/services/category.dart';

import 'package:exinflow/models/account.dart';
import 'package:exinflow/models/category.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final user = FirebaseAuth.instance.currentUser;
  final AccountService accountService = AccountService();
  final CategoryService categoryService = CategoryService();

  final AccountController accountController = Get.find<AccountController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final IconController iconController = Get.find<IconController>();
  final ColorController colorController = Get.find<ColorController>();

  final String id;
  final String title;
  final String menu;
  final String page;
  final String type;
  final String from;
  final String subtype;
  final int subIndex;
  final double height = kToolbarHeight;

  TopBar({Key? key, required this.id, required this.title, required this.menu, required this.page, required this.type, required this.from, required this.subtype, required this.subIndex}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(100),
      child: SafeArea(
        child: Container(
          height: 100,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  context.pop();
                  
                  if(type != 'edit' || (type == 'edit' && from == 'dots')) {
                    if(menu == "Akun") {
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
                  }
                },
                style: OutlinedButton.styleFrom(
                  shape: CircleBorder(),
                  side: BorderSide(width: 1, color: mainBlue),
                  padding: EdgeInsets.zero,
                  minimumSize: Size(40, 40),
                ),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: mainBlue,
                  size: 40
                ),
              ),
        
              Padding(
                padding: EdgeInsets.only(
                  left: page == 'All' ? 0 : type == 'view' ? 52 : 0,
                  right: page == 'All' || type == 'view' ? 0 : 47
                ),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: small,
                      fontFamily: "Open Sans",
                      fontWeight: FontWeight.w600,
                      color: greyMinusOne
                    ),
                  ),
                ),
              ),
        
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if(page == 'All')
                    OutlinedButton(
                      onPressed: () {
                        if(menu == "Akun") {
                          context.push('/manage/accounts/account');
                        }
                        if(menu == "Kategori") {
                          if(subtype == 'category') {
                            context.push('/manage/categories/category');
                          }
                          if(subtype == 'subcategory') {
                            context.push('/manage/categories/category/$id/subcategory');
                          }
                        }
                        if(menu == "Transaksi") {
                          if(subtype == 'transaction') {
                            context.push('/manage/transactions/transaction');
                          }
                          if(subtype == 'template') {
                            context.push('/manage/transactions/template');
                          }
                          if(subtype == 'plan') {
                            context.push('/manage/transactions/plan');
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        shape: CircleBorder(),
                        side: BorderSide(width: 1, color: mainBlue),
                        backgroundColor: mainBlue,
                        padding: EdgeInsets.zero,
                        minimumSize: Size(40, 40),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 30
                      ),
                    ),
        
                  if(page == "Detail" && type == 'view')
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: OutlinedButton(
                        onPressed: () {
                          if(menu == "Akun") {
                            context.push('/manage/accounts/account/$id?action=edit&from=bar');
                          }
                          if(menu == "Kategori") {
                            if(subtype == 'category') {
                              context.push('/manage/categories/category/${id}?action=edit&from=bar');
                            }
                            if(subtype == 'subcategory') {
                              context.push('/manage/categories/category/${id}/subcategory/$subIndex?action=edit&from=bar');
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          shape: CircleBorder(),
                          side: BorderSide(width: 1, color: mainBlue),
                          padding: EdgeInsets.zero,
                          minimumSize: Size(40, 40),
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          color: mainBlue,
                          size: 25
                        ),
                      ),
                    ),
                  if(page == "Detail" && type == 'view')
                    OutlinedButton(
                      onPressed: ((menu == 'Akun' && accountController.accountLength == 1) || (menu == 'Kategori' && categoryController.categoryLength == 1)) ? null : () async {
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
                          Map<String, dynamic> result = {};

                          if(menu == "Akun") {
                            result = await accountService.deleteAccount(user?.uid ?? '', id);

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
                          
                          if(menu == "Kategori") {
                            if(subtype == 'category') {
                              result = await categoryService.deleteCategory(user?.uid ?? '', id);

                              categoryController.setSubcategory(-1);
                              categoryController.setCategory(
                                CategoryModel(
                                  id: '',
                                  name: '',
                                  typeId: -1,
                                  subs: null,
                                  icon: '',
                                  color: '',
                                )
                              );
                            }
                            if(subtype == 'subcategory') {
                              result = await categoryService.deleteSubcategory(user?.uid ?? '', id, subIndex);

                              categoryController.setSubcategory(-1);
                              categoryController.setCategory(
                                CategoryModel(
                                  id: '',
                                  name: '',
                                  typeId: -1,
                                  subs: null,
                                  icon: '',
                                  color: '',
                                )
                              );
                            }
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        shape: CircleBorder(),
                        side: BorderSide(width: 1, color: mainBlue),
                        padding: EdgeInsets.zero,
                        minimumSize: Size(40, 40),
                      ),
                      child: Icon(
                        Icons.delete_outlined,
                        color: mainBlue,
                        size: 27.5
                      ),
                    )
                ],
              )
            ],
          )
        ),
      )
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}