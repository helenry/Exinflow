import 'package:exinflow/controllers/user.dart';
import 'package:exinflow/models/credit.dart';
import 'package:exinflow/services/credit.dart';
import 'package:exinflow/widgets/alert.dart';
import 'package:exinflow/widgets/padding.dart';
import 'package:exinflow/widgets/select_icon.dart';
import 'package:exinflow/widgets/select_color.dart';
import 'package:flutter/material.dart';
import 'package:exinflow/widgets/top_bar.dart';
import 'package:exinflow/constants/constants.dart';
import 'package:exinflow/constants/data.dart';
import 'package:exinflow/controllers/credit.dart';
import 'package:exinflow/controllers/account.dart';
import 'package:exinflow/controllers/user.dart';
import 'package:exinflow/controllers/icon.dart';
import 'package:exinflow/controllers/color.dart';
import 'package:exinflow/models/account.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreditDetail extends StatefulWidget {
  final String id;
  final String action;
  final String from;
  final String sub;

  CreditDetail({
    Key? key,
    required this.id,
    required this.action,
    required this.from,
    required this.sub,
  }): super(key: key);

  @override
  State<CreditDetail> createState() => _CreditDetailState();
}

class _CreditDetailState extends State<CreditDetail> {
  final user = FirebaseAuth.instance.currentUser;
  final CreditService creditService = CreditService();

  final CreditController creditController = Get.find<CreditController>();
  final AccountController accountController = Get.find<AccountController>();
  final UserController userController = Get.find<UserController>();
  final IconController iconController = Get.find<IconController>();
  final ColorController colorController = Get.find<ColorController>();

  CreditModel current = CreditModel(
    id: '',
    provider: '',
    limitAmount: 0,
    currency: '',
    limits: null,
    dueDate: 0,
    cutOffDate: 0,
    icon: '',
    color: '',
    isDeleted: false
  );

  @override
  void initState() {
    super.initState();
    current.provider = widget.action == 'add' ? '' : creditController.credit?.provider ?? '';
    current.limitAmount = widget.action == 'add' ? 0 : creditController.credit?.limitAmount ?? 0;
    current.currency = widget.action == 'add' ? userController.user?.mainCurrency ?? '' : creditController.credit?.currency ?? '';
    current.dueDate = widget.action == 'add' ? 0 : creditController.credit?.dueDate ?? 0;
    current.cutOffDate = widget.action == 'add' ? 0 : creditController.credit?.cutOffDate ?? 0;
    current.icon = widget.action == 'add' ? '' : creditController.credit?.icon ?? '';
    current.color = widget.action == 'add' ? '' : creditController.credit?.color ?? '';

    iconController.changeIcon('');
    colorController.changeColor('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        id: widget.id,
        title: "Detail",
        menu: "Kredit",
        page: "Detail",
        type: widget.action,
        from: widget.from,
        subtype: '',
        subIndex: -1,
      ),

      body: Center(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: AllPadding(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 75),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 17.5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                "Penyedia",
                                style: TextStyle(
                                  fontSize: small,
                                  color: greyMinusTwo
                                ),
                              ),
                            ),
                            TextFormField(
                              enabled: widget.action == 'add' || widget.action == 'edit' ? true : false,
                              onChanged: (value) {
                                setState(() {
                                  current.provider = value;
                                });
                              },
                              initialValue: current.provider,
                              style: TextStyle(
                                fontSize: semiVerySmall
                              ),
                              decoration: InputDecoration(
                                hintText: widget.action == 'view' ? creditController.credit?.provider ?? '' : 'Nama penyedia',
                                hintStyle: TextStyle(
                                  color: greyMinusThree
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: mainBlueMinusThree),
                                  borderRadius: borderRadius
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: greyMinusFour),
                                  borderRadius: borderRadius
                                ),
                              ),
                              keyboardType: TextInputType.name,
                            )
                          ],
                        ),
                      ),
                  
                      Padding(
                        padding: const EdgeInsets.only(bottom: 17.5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                "Limit",
                                style: TextStyle(
                                  fontSize: small,
                                  color: greyMinusTwo
                                ),
                              ),
                            ),
                            TextFormField(
                              enabled: widget.action == 'add' ? true : false,
                              onChanged: (value) {
                                setState(() {
                                  current.limitAmount = double.tryParse(value) ?? 0;
                                });
                              },
                              initialValue: current.limitAmount.toString(),
                              style: TextStyle(
                                fontSize: semiVerySmall
                              ),
                              decoration: InputDecoration(
                                hintText: widget.action == 'view' ? creditController.credit?.limitAmount.toString() ?? '' : 'Limit pemakaian',
                                hintStyle: TextStyle(
                                  color: greyMinusThree
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: mainBlueMinusThree),
                                  borderRadius: borderRadius
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: greyMinusFour),
                                  borderRadius: borderRadius
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            )
                          ],
                        ),
                      ),
                  
                      Padding(
                        padding: const EdgeInsets.only(bottom: 17.5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                "Mata Uang",
                                style: TextStyle(
                                  fontSize: small,
                                  color: greyMinusTwo
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(color: greyMinusFour, width: 1),
                                  borderRadius: borderRadius,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: current.currency,
                                      items: currencies.map((currency) {
                                        return DropdownMenuItem(
                                          value: currency['ISO_Code'],
                                          child: Text(currency['Name_ID'] ?? ''),
                                        );
                                      }).toList(),
                                      style: TextStyle(
                                        fontSize: semiVerySmall,
                                        color: greyMinusTwo
                                      ),
                                      onChanged: widget.action == 'add' || widget.action == 'edit' ? (value) {
                                        setState(() {
                                          current.currency = value ?? '';
                                        });
                                      } : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 17.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(right: 7.5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        "Tanggal Bayar",
                                        style: TextStyle(
                                          fontSize: small,
                                          color: greyMinusTwo
                                        ),
                                      ),
                                    ),
                                    TextFormField(
                                      enabled: widget.action == 'add' || widget.action == 'edit' ? true : false,
                                      onChanged: (value) {
                                        setState(() {
                                          current.dueDate = int.tryParse(value) ?? 0;
                                        });
                                      },
                                      initialValue: current.dueDate.toString(),
                                      style: TextStyle(
                                        fontSize: semiVerySmall
                                      ),
                                      decoration: InputDecoration(
                                        hintText: widget.action == 'view' ? creditController.credit?.dueDate.toString() ?? '' : 'Tagihan',
                                        hintStyle: TextStyle(
                                          color: greyMinusThree
                                        ),
                                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(width: 1, color: mainBlueMinusThree),
                                          borderRadius: borderRadius
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(width: 1, color: greyMinusFour),
                                          borderRadius: borderRadius
                                        ),
                                      ),
                                      keyboardType: TextInputType.name,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(right: 7.5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        "Tanggal Tagihan",
                                        style: TextStyle(
                                          fontSize: small,
                                          color: greyMinusTwo
                                        ),
                                      ),
                                    ),
                                    TextFormField(
                                      enabled: widget.action == 'add' || widget.action == 'edit' ? true : false,
                                      onChanged: (value) {
                                        setState(() {
                                          current.cutOffDate = int.tryParse(value) ?? 0;
                                        });
                                      },
                                      initialValue: current.cutOffDate.toString(),
                                      style: TextStyle(
                                        fontSize: semiVerySmall
                                      ),
                                      decoration: InputDecoration(
                                        hintText: widget.action == 'view' ? creditController.credit?.cutOffDate.toString() ?? '' : 'Bayar',
                                        hintStyle: TextStyle(
                                          color: greyMinusThree
                                        ),
                                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(width: 1, color: mainBlueMinusThree),
                                          borderRadius: borderRadius
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(width: 1, color: greyMinusFour),
                                          borderRadius: borderRadius
                                        ),
                                      ),
                                      keyboardType: TextInputType.name,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  
                      Padding(
                        padding: const EdgeInsets.only(bottom: 17.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    "Ikon",
                                    style: TextStyle(
                                      fontSize: small,
                                      color: greyMinusTwo
                                    ),
                                  ),
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: greyMinusFour, width: 1),
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.all(0),
                                    padding: EdgeInsets.all(0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Obx(() {
                                        return IconButton(
                                          icon: iconController.selectedIcon.value != '' ? Obx(() {
                                            return Icon(
                                              icons[iconController.selectedIcon.value],
                                              size: 30,
                                              color: greyMinusTwo
                                            );
                                          }) : Icon(
                                            widget.action == 'view' ? icons[current.icon] : widget.action == 'add' ? iconController.selectedIcon.value != '' ? icons[iconController.selectedIcon.value] : Icons.add_rounded : iconController.selectedIcon.value != '' ? icons[iconController.selectedIcon.value] : icons[current.icon],
                                            size: 30,
                                            color: greyMinusTwo
                                          ),
                                          onPressed: widget.action == 'add' || widget.action == 'edit' ? () {
                                            SelectIcon selectIcon = SelectIcon();
                                            selectIcon.show(context);
                                          } : null,
                                        );
                                      }),
                                    )
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    "Warna",
                                    style: TextStyle(
                                      fontSize: small,
                                      color: greyMinusTwo
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 285,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: greyMinusFour, width: 1),
                                      borderRadius: borderRadius
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                      child: Obx(() {
                                        return Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          child: colorController.selectedColor.value != '' ? Obx(() {
                                            return ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(int.parse("FF${colorController.selectedColor.value}", radix: 16)),
                                                disabledBackgroundColor: Color(int.parse("FF${colorController.selectedColor.value}", radix: 16)),
                                              ),
                                              child: Text(
                                                '',
                                                style: TextStyle(
                                                  fontSize: semiVerySmall
                                                )
                                              ),
                                              onPressed: widget.action == 'add' || widget.action == 'edit' ? () {
                                                SelectColor selectColor = SelectColor();
                                                selectColor.show(context);
                                              } : null,
                                            );
                                          }) : ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              disabledBackgroundColor: Color(int.parse("FF${widget.action == 'view' ? current.color : widget.action == 'add' ? colorController.selectedColor.value != '' ? colorController.selectedColor.value : '0f667b' : colorController.selectedColor.value != '' ? colorController.selectedColor.value : current.color}", radix: 16)),
                                              backgroundColor: Color(int.parse("FF${widget.action == 'view' ? current.color : widget.action == 'add' ? colorController.selectedColor.value != '' ? colorController.selectedColor.value : '0f667b' : colorController.selectedColor.value != '' ? colorController.selectedColor.value : current.color}", radix: 16)),
                                            ),
                                            child: Text(
                                              '',
                                              style: TextStyle(
                                                fontSize: semiVerySmall
                                              )
                                            ),
                                            onPressed: widget.action == 'add' || widget.action == 'edit' ? () {
                                              SelectColor selectColor = SelectColor();
                                              selectColor.show(context);
                                            } : null,
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              )
            ),

            AllPadding(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: widget.action == 'view' ? null : OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: widget.action == 'add' || widget.action == 'edit' ? mainBlueMinusTwo : Colors.transparent,
                    side: BorderSide(color: widget.action == 'add' || widget.action == 'edit' ? Colors.transparent : mainBlueMinusTwo),
                    padding: EdgeInsets.all(widget.action == 'add' || widget.action == 'edit' ? 15 : 5)
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Simpan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: small,
                            fontWeight: FontWeight.w500
                          )
                        )
                      ],
                    ),
                  ),
                  onPressed: () async {
                    CreditModel data = current;
                    Map<String, dynamic> result = {};
                    if(current.provider == '') {
                      result = {
                        'success': false,
                        'message': 'Nama penyedia harus diisi'
                      };
                      print(result);
                    } else {
                      if(widget.action == 'add') {
                        data.icon = iconController.selectedIcon.value == '' ? 'account_balance_wallet_outlined' : iconController.selectedIcon.value;
                        data.color = colorController.selectedColor.value == '' ? '0f667b' : colorController.selectedColor.value;

                        result = await creditService.createCredit(user?.uid ?? '', data);
                      } else if(widget.action == 'edit') {
                        data.icon = iconController.selectedIcon.value == '' ? current.icon : iconController.selectedIcon.value;
                        data.color = colorController.selectedColor.value == '' ? current.color : colorController.selectedColor.value;

                        result = await creditService.updateCredit(user?.uid ?? '', widget.id, data);
                      }

                      if(result['success'] == true) {
                        context.pop();
                      }
                    }
                  },
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}