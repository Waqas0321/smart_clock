import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_clock/View/bottom_navigation.dart';
import 'package:smart_clock/homepage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
   @override
  void initState() {
    super.initState();

    // Add a delay before navigating to the main screen
    Timer(
      const Duration(seconds: 3),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ScreenUtil().screenWidth > 600?  const HomePage(): BottomNavigation(),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff2a2a2a),
      body: Stack(
        children: [
          Center(child: Image.asset("assets/icon.png",height: 0.2.sh, width: 0.2.sh,)),
          Positioned(bottom:0.05.sh, right:0, left:0, child: Image.asset("assets/smartclock.png")),
        ],
      ),
    );
  }
}