import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_clock/utils/Colors.dart';

class Clock extends StatefulWidget {
  final String screen;
  const Clock({super.key, required this.screen});

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  late String currentTime;
  late String currentDay;
  late String currentCity;
  late String hours;
  late String minutes;
  late String seconds;
  late String dayTime;
 
  @override
  void initState() {
    super.initState();
    // Initialize the time, day, and city
    updateTime();

    // Update the time every second
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
    if(mounted)
      {
        setState(() {
          updateTime();
        });
      }
    });
  }
  

  void updateTime() {
    DateTime now = DateTime.now();
    hours = DateFormat('hh').format(now);
    minutes = DateFormat('mm').format(now);
    seconds = DateFormat('ss').format(now);
    dayTime = DateFormat('a').format(now);

    currentTime = DateFormat('hh:mm:ss a').format(now);

    currentDay = DateFormat('EEEE').format(now);

    currentCity = 'YourCity';
  }

  @override
  Widget build(BuildContext context) {
    return  widget.screen == "tablet"?
    Container(
      decoration: BoxDecoration(
        // color: Color.fromARGB(255, 150, 134, 133),
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
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical:0.03.sh, horizontal: 0.03.sw),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
              children: [
             
                Text(
                  currentDay,
                  style: GoogleFonts.bebasNeue(
                    fontWeight: FontWeight.w500,
                    color: CustomColor.primaryColor,
                    fontSize: 15.sp,
                    height: 1
                  ),
                ),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                Text(
                  hours,
                  style:GoogleFonts.bebasNeue(
                    fontWeight: FontWeight.w500,
                    color: CustomColor.primaryColor,
                    fontSize: 40.sp,
                    height: 0.7
        
                  ),
                ),
                Text(
                  ':',
                  style:GoogleFonts.bebasNeue(
                    fontWeight: FontWeight.w500,
                    color: CustomColor.primaryColor,
                    fontSize: 40.sp,
                    height: 0.7
                  ),
                ),
                Text(
                  minutes,
                  style:GoogleFonts.bebasNeue(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFFB7800),
                    fontSize: 40.sp,
                    height: 0.7
        
                  ),
                ),
        
                SizedBox(width: 0.02.sw),
        
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      seconds,
                      style:GoogleFonts.bebasNeue(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFB7800),
                        fontSize: 35.sp,
                        height: 0
        
                      ),
                    ),
                    const SizedBox(width: 6,),
                    Text(
                      dayTime,
                      style:GoogleFonts.bebasNeue(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFB7800),
                        fontSize: 35.sp,
                        height: 0
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    )
    :
    Container(
      decoration: BoxDecoration(
        // color: Color.fromARGB(255, 150, 134, 133),
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
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical:0.02.sh, horizontal: 0.02.sw),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
              children: [
             
                Text(
                  currentDay,
                  style: GoogleFonts.bebasNeue(
                    fontWeight: FontWeight.w500,
                    color: CustomColor.primaryColor,
                    fontSize: 20.sp,
                    height: 1.5
                  ),
                ),
                const SizedBox(height: 10,),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                Text(
                  hours,
                  style:GoogleFonts.bebasNeue(
                    fontWeight: FontWeight.w500,
                    color: CustomColor.primaryColor,
                    fontSize: 100.sp,
                    height: 0.7
        
                  ),
                ),
                Text(
                  ':',
                  style:GoogleFonts.bebasNeue(
                    fontWeight: FontWeight.w500,
                    color: CustomColor.primaryColor,
                    fontSize: 100.sp,
                    height: 0.7
                  ),
                ),
                Text(
                  minutes,
                  style:GoogleFonts.bebasNeue(
                    fontWeight: FontWeight.w500,
                    color: CustomColor.primaryColor,
                    fontSize: 100.sp,
                    height: 0.7
        
                  ),
                ),
        
                SizedBox(width: 0.04.sw),
        
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      seconds,
                      style:GoogleFonts.bebasNeue(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFB7800),
                        fontSize: 30.sp,
                        height: 0
        
                      ),
                    ),
                    
                    Text(
                      dayTime,
                      style:GoogleFonts.bebasNeue(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFB7800),
                        fontSize: 30.sp,
                        height: 0
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}