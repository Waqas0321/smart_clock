import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomColor{
  static const Color primaryColor = Color(0xFFFB7800);
  static const Color backgroundColor = Color(0xFF1b1b1b);
  static const Color lightgreyColor = Color(0xFF616161);
  static const Color darkgreyColor = Color(0xFF242424);
  static const Color textBlueColor = Color(0xFFace2fa);
  static const Color textPinkColor = Color(0xffc0c0c0);
  static const Color textGreenColor = Color(0xFFddfc9c);
  static const Color textGoldenDarkColor = Color(0xFFfae7b5);
  static const Color textGoldenLightColor = Color.fromARGB(255, 190, 173, 131);
  static var boxDecoration = BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10.r)),
        border: Border.all(
          width: 2,
          color: CustomColor.lightgreyColor
        ),
        gradient: const LinearGradient(
          colors: [CustomColor.darkgreyColor, CustomColor.lightgreyColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
}