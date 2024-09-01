import 'package:exinflow/controllers/subtab.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exinflow/constants/constants.dart';

class Subtab extends StatelessWidget {
  final List<Map> tabs;
  final TabController controller;
  final SubtabController subtabController = Get.find<SubtabController>();

  Subtab({Key? key, required this.tabs, required this.controller}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Center(
        child: Obx(() {
          return DefaultTabController(
            initialIndex: subtabController.selectedTab.value,
            length: tabs.length,
            child: IntrinsicWidth(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(color: mainBlue)
                ),
                
                child: TabBar(
                  controller: controller,
                  onTap: (i) {
                    subtabController.changeTab(i);
                  },
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  indicator: BoxDecoration(
                    color: mainBlue,
                    borderRadius: borderRadius
                  ),
                  indicatorColor: mainBlue,
                  splashBorderRadius: borderRadius,
                  overlayColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      return states.contains(MaterialState.focused) ? null : Colors.transparent;
                    }
                  ),
                  labelColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.tab,
                  unselectedLabelColor: mainBlue,
                  dividerColor: Colors.transparent,
                  labelPadding: EdgeInsets.symmetric(horizontal: 20),
                  labelStyle: TextStyle(
                    fontSize: tiny,
                    fontWeight: FontWeight.w500
                  ),
                  tabs: tabs.map((tab) {
                    return Container(
                      height: 30,
                      child: Tab(
                        text: tab["tab"]
                      ),
                    );
                  }).toList()
                ),
              ),
            )
          );
        }),
      ),
    );
  }
}