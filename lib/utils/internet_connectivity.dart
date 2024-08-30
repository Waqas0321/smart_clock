  import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showNoInternetSnackbar() {
    Get.snackbar(
      backgroundColor:Colors.white,
      'No internet connection',
      'Please check your internet connection',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 500),
    );
  }