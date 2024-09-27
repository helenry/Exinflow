import 'package:exinflow/controllers/subtab.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exinflow/constants/constants.dart';

class Subtab extends StatefulWidget {
  final List<Map> tabs;
  final String type;
  final bool disabled;
  final TabController controller;


  Subtab({Key? key, required this.tabs, required this.type, required this.disabled, required this.controller}): super(key: key);

  @override
  State<Subtab> createState() => _SubtabState();
}

class _SubtabState extends State<Subtab> {
  final AllSubtabController allSubtabController = Get.find<AllSubtabController>();
  final OneSubtabController oneSubtabController = Get.find<OneSubtabController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Center(
        child: Obx(() {
          return DefaultTabController(
            initialIndex: widget.type == 'all' ? allSubtabController.selectedTab.value : oneSubtabController.selectedTab.value,
            length: widget.tabs.length,
            child: IntrinsicWidth(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(color: mainBlue)
                ),
                
                child: IgnorePointer(
                  ignoring: widget.disabled,
                  child: TabBar(
                    controller: widget.controller,
                    onTap: (i) {
                      widget.type == 'all' ? allSubtabController.changeTab(i) : oneSubtabController.changeTab(i);
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
                    tabs: widget.tabs.map((tab) {
                      return Container(
                        height: 30,
                        child: Tab(
                          text: tab["tab"]
                        ),
                      );
                    }).toList()
                  ),
                ),
              ),
            )
          );
        }),
      ),
    );
  }
}