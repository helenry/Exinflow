import 'package:flutter/material.dart';
import 'package:exinflow/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class BottomBar extends StatefulWidget {
  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int selectedMenu = 0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: radius,
        topRight: radius,
      ),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: mainBlue.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 4),
            )
          ]
        ),
        child: NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          selectedIndex: selectedMenu,
          indicatorColor: Colors.transparent,
          shadowColor: Colors.transparent,
          backgroundColor: mainBlueMinusFive,
          onDestinationSelected: (i) {
            setState(() {
              selectedMenu = i;
            });

            switch(i) {
              case 0:
                context.go('/home');
                break;
              case 1:
                context.go('/manage');
                break;
              case 2:
                context.push('/speechrecognition');
                break;
              case 3:
                context.go('/analytics');
                break;
              case 4:
                context.go('/account');
                break;
            }
          },
          destinations: [
            Container(
              color: mainBlueMinusFive,
              child: NavigationDestination(
                icon: Icon(
                  Icons.home_rounded,
                  size: 25,
                  color: selectedMenu == 0 ? mainBlue : greyPlusOne
                ),
                label: "Beranda",
              ),
            ),
            Container(
              color: mainBlueMinusFive,
              child: NavigationDestination(
                icon: Icon(
                  Icons.tsunami_outlined,
                  size: 25,
                  color: selectedMenu == 1 ? mainBlue : greyPlusOne
                ),
                label: "Atur"
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  color: mainBlue,
                  borderRadius: borderRadiusPlusOne,
                ),
                child: NavigationDestination(
                  icon: Icon(
                    Icons.mic_rounded,
                    size: 27.5,
                    color: Colors.white,
                  ),
                  label: "Bicara",
                ),
              ),
            ),
            Container(
              color: mainBlueMinusFive,
              child: NavigationDestination(
                icon: Icon(
                  Icons.area_chart_outlined,
                  size: 25,
                  color: selectedMenu == 3 ? mainBlue : greyPlusOne
                ),
                label: "Analitik"
              ),
            ),
            Container(
              color: mainBlueMinusFive,
              child: NavigationDestination(
                icon: Icon(
                  Icons.perm_identity_rounded,
                  size: 25,
                  color: selectedMenu == 4 ? mainBlue : greyPlusOne
                ),
                label: "Akun"
              ),
            ),
          ],
        ),
      )
    );
  }
}