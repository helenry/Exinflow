import 'package:exinflow/constants/constants.dart';
import 'package:exinflow/controllers/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:exinflow/widgets/padding.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

class Onboarding extends StatefulWidget {
  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int page = 1;
  final List<Map> contents = [
    {
      "button": "Mulai",
      "title": "Atur\nKeuangan\nAnda",
      "text": "Dari transaksi sehari-hari, tabungan, anggaran, hingga kredit"
    },
    {
      "button": "Lanjut",
      "title": "Dengan\nSpeech\nRecognition",
      "text": "Gunakan suara untuk mengatur keuangan dengan cepat"
    },
    {
      "button": "Gunakan",
      "title": "Mulai\nExinflow\nSekarang",
      "text": "Mulai gunakan untuk pengalaman mengatur keuangan yang efektif"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final OnboardingController onboardingController = Get.find();

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/onboarding/$page.png"),
              fit: BoxFit.cover
            )
          ),
          child: AllPadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 160),
                  child: Center(
                    child: Container(
                      width: 125,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(
                          contents.length,
                          (index) => Container(
                            width: 35,
                            child: OutlinedButton(
                              child: Text(
                                (index + 1).toString(),
                                style: TextStyle(
                                  fontSize: veryTiny,
                                  fontWeight: FontWeight.w400,
                                  color: page == index + 1 ? mainBlueMinusOne : Colors.white
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: CircleBorder(),
                                side: BorderSide(color: Colors.white),
                                backgroundColor: page == index + 1 ? Colors.white : Colors.transparent,
                                padding: EdgeInsets.zero
                              ),
                              onPressed: () {
                                setState(() {
                                  page = index + 1;
                                });
                              },
                            ),
                          )
                        )
                      ),
                    )
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: Text(
                    contents[page - 1]["title"],
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.15,
                      fontFamily: "Open Sans",
                      fontSize: veryLarge,
                      fontWeight: FontWeight.w500
                    )
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(bottom: 50),
                  child: Text(
                    contents[page - 1]["text"],
                    style: TextStyle(
                      color: greyMinusFour,
                      fontSize: verySmall,
                    )
                  ),
                ),

                ClipRRect(
                  borderRadius: borderRadius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: OutlinedButton(
                      onPressed: () async {
                        if(page != contents.length) {
                          setState(() {
                            page += 1;
                          });
                        } else {
                          await onboardingController.completeOnboarding();
                          context.go('/signinup?type=0');
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: borderRadius,
                        ),
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                      child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              child: Text(
                                contents[page - 1]["button"],
                                style: TextStyle(
                                  color: greyMinusFour,
                                  fontSize: semiVerySmall,
                                )
                              ),
                            ),
                            Icon(
                              page != 3 ? Icons.arrow_forward_rounded : Icons.arrow_outward_rounded,
                              color: greyMinusFour,
                              size: 25,
                            )
                          ],
                        ),
                      ),
                    )
                  )
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}