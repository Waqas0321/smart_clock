import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_clock/utils/Colors.dart';

class Calender extends StatefulWidget {
  final String screen;
  const Calender({super.key, required this.screen});

  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  final List<DateTime?> _singleDatePickerValueWithDefaultValue = [
    DateTime.now(),
  ];

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;

    void showCalendarDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Container(
              width: 0.8.sw,
              padding: const EdgeInsets.all(8.0),
              color: CustomColor.lightgreyColor,
              child: CalendarDatePicker2(
                config: CalendarDatePicker2Config(
                  calendarType: CalendarDatePicker2Type.single,
                  selectedDayHighlightColor: Colors.indigo,
                  dayTextStyle: TextStyle(
                    color: CustomColor.textGreenColor,
                    fontWeight: FontWeight.bold,
                    fontSize: (orientation == Orientation.landscape) ? 20.sp : 15.sp,
                  ),
                  weekdayLabelTextStyle: TextStyle(
                    color: CustomColor.textGreenColor,
                    fontSize: (orientation == Orientation.landscape) ? 20.sp : 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  controlsTextStyle: TextStyle(
                    color: CustomColor.textGreenColor,
                    fontSize: (orientation == Orientation.landscape) ? 20.sp : 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedDayTextStyle: TextStyle(
                    color: CustomColor.textGreenColor,
                    fontSize: (orientation == Orientation.landscape) ? 20.sp : 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                value: _singleDatePickerValueWithDefaultValue,
              ),
            ),
          );
        },
      );
    }

    return widget.screen == "tablet"
        ? GestureDetector(
            onTap: showCalendarDialog,
            child: Container(
              height: (orientation == Orientation.portrait) ? 0.16.sh : 0.31.sh,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.r)),
                border: Border.all(
                  width: 2,
                  color: CustomColor.lightgreyColor,
                ),
                gradient: const LinearGradient(
                  colors: [CustomColor.darkgreyColor, CustomColor.lightgreyColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.calendar_today,
                size: (orientation == Orientation.portrait) ? 50.sp : 70.sp,
                color: CustomColor.textGreenColor,
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Container(
              height: 0.35.sh,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.r)),
                border: Border.all(
                  width: 2,
                  color: CustomColor.lightgreyColor,
                ),
                gradient: const LinearGradient(
                  colors: [CustomColor.darkgreyColor, CustomColor.lightgreyColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: CalendarDatePicker2(
                config: CalendarDatePicker2Config(
                  calendarType: CalendarDatePicker2Type.single,
                  selectedDayHighlightColor: Colors.indigo,
                  dayTextStyle: TextStyle(
                    color: CustomColor.textGreenColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                  weekdayLabelTextStyle: TextStyle(
                    color: CustomColor.textGreenColor,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  controlsTextStyle: TextStyle(
                    color: CustomColor.textGreenColor,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedDayTextStyle: TextStyle(
                    color: CustomColor.textGreenColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                value: _singleDatePickerValueWithDefaultValue,
              ),
            ),
          );
  }
}
