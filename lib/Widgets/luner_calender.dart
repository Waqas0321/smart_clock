import 'package:chinese_lunar_calendar/chinese_lunar_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/Colors.dart';

class LunerCalender extends StatefulWidget {
  final String screen;
  const LunerCalender({super.key, required this.screen});

  @override
  State<LunerCalender> createState() => _LunerCalenderState();
}

class _LunerCalenderState extends State<LunerCalender> {
  @override
  Widget build(BuildContext context) {
    // Ensure the current date is used and converted to UTC for accurate lunar date calculation
    DateTime now = DateTime.now();
    DateTime nowUtc = now.toUtc();
    final lunarCalendar = LunarCalendar(utcDateTime: nowUtc);

  //  var orientation = MediaQuery.of(context).orientation;
    return Padding(
      padding: const EdgeInsets.only(right: 8, left: 8, top: 8.0),
      child: widget.screen == "tablet"
          ? Container(
              decoration: CustomColor.boxDecoration,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "GREGORIAN DATE: ${now.day}/${now.month}/${now.year}",
                          style: GoogleFonts.bebasNeue(
                            color: CustomColor.textGreenColor,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "LUNAR DATE: ${lunarCalendar.lunarDate.day}/${lunarCalendar.lunarDate.month}/${lunarCalendar.lunarDate.year}",
                          style: GoogleFonts.bebasNeue(
                            color: CustomColor.textGreenColor,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Container(
              decoration: CustomColor.boxDecoration,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "GREGORIAN DATE: ${now.day}/${now.month}/${now.year}",
                          style: GoogleFonts.bebasNeue(
                            color: CustomColor.textGreenColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "LUNAR DATE: ${lunarCalendar.lunarDate.day}/${lunarCalendar.lunarDate.month}/${lunarCalendar.lunarDate.year}",
                          style: GoogleFonts.bebasNeue(
                            color: CustomColor.textGreenColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
