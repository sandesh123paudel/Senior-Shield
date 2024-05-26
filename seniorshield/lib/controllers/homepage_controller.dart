
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController{
  var currentNavIndex=0.obs;

  Color getIconColor(int index) {
    return currentNavIndex.value == index ? Colors.white : Colors.grey;
  }
}