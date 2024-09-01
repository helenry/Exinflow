import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubtabController extends GetxController {
  var selectedTab = 0.obs;

  void changeTab(int index) {
    selectedTab.value = index;
  }
}