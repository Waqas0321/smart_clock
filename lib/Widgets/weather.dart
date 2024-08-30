import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_clock/Widgets/alarm_main.dart';
import 'package:smart_clock/Widgets/running_line.dart';
import 'package:smart_clock/page.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:smart_clock/Controller/weather_controller.dart';
import 'package:get/get.dart';
import 'package:smart_clock/utils/Colors.dart';

class Weather extends StatefulWidget {
  final String screen;
  const Weather({super.key, required this.screen});

  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  WeatherController weatherController = Get.put(WeatherController());
  late String hours;
  late String minutes;
  late String seconds;
  late String dayTime;
  late String currentDay;

  @override
  void initState() {
    super.initState();
    
    updateTime();
    
    Timer.periodic(const Duration(seconds: 60), (Timer timer) {
      if (mounted) {
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
    currentDay = DateFormat('EEEE').format(now);
  }

void _showClockAlarmDialog(BuildContext context) {
  // Create a TimePickerDialog to select the alarm time
  showTimePicker(
    initialTime: TimeOfDay.now(),
    context: context,
    builder: (BuildContext context, Widget? child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      );
    },
  ).then((selectedTime) {
    if (selectedTime != null) {
      _scheduleAlarm(selectedTime);
    }
  });
}

void _scheduleAlarm(TimeOfDay selectedTime) async {
  // Create a notification channel
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('your_icon_name'); // Replace with your icon resource name

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize the notification channel
  await flutterLocalNotificationsPlugin.initialize(
  const InitializationSettings(
      android: initializationSettingsAndroid,
    ),
  );

  // Create a notification
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          'alarm_channel',
          'Alarm Channel',
          importance: Importance.max,
          priority: Priority.high);

  // Calculate the next alarm time
  DateTime now = DateTime.now();
  DateTime selectedDateTime = DateTime(
      now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);

  // Schedule the notification at the selected time (remove deprecated parameter)
  await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Alarm',
      'Wake up!',
      tz.TZDateTime.from(selectedDateTime, tz.local),
      const NotificationDetails(
        android: androidPlatformChannelSpecifics,
      ),
     // androidScheduleMode: ScheduleMode.EXACT, // Recommended for precise scheduling
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
  );
}

Widget ClockButton() {
  return 
   GestureDetector(
      onTap: () {
     Navigator.push(
    context,
    MaterialPageRoute(builder: (context) =>const AlarmHomeScreen()),
  ); // Open a dialog box
      },
      child: Container(
        height: 30,
        width: 50,
        decoration:const  BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
         
        ),
        child:const Center(
          child: Icon(
            Icons.alarm_add_sharp,
            color: Colors.white,
            size: 18,
            
          ),
        ),
      ));
}

  @override
Widget build(BuildContext context) {
  var orientation = MediaQuery.of(context).orientation;
return widget.screen == "tablet"
    ? Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: (orientation == Orientation.portrait) ? 0.7.sh : 0.54.sh,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.r)),
                border: Border.all(width: 2, color: CustomColor.lightgreyColor),
                gradient: const LinearGradient(
                  colors: [CustomColor.darkgreyColor, CustomColor.lightgreyColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [

                          Obx(() => Image.asset(
                                weatherController.conditionImage.value,
                                height: 0.1.sh,
                                width: 0.1.sh,
                              )),
                          Obx(
                            () => Text(
                              weatherController.weatherModel.value.main == null
                                  ? ""
                                  : weatherController.weatherModel.value.weather![0].main!,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: CustomColor.textBlueColor,
                                fontSize: 25.sp, // Reduced font size
                                height: 1.2,
                              ),
                            ),
                          ),
                          ClockButton(),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Obx(
                            () => Text(
                              weatherController.weatherModel.value.main == null
                                  ? "00°"
                                  : "${weatherController.weatherModel.value.main!.temp!.toInt()}°",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: CustomColor.textBlueColor,
                                fontSize: 44.sp, // Reduced font size
                                height: 1.2,
                              ),
                            ),
                          ),
                           Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),                                              
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                  Text(
                                    hours,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: CustomColor.textBlueColor,
                                      fontSize: 20.sp, // Reduced font size
                                      height: 1.2,
                                    ),
                                  ),
                                  Text(
                                    ':',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: CustomColor.textBlueColor,
                                      fontSize: 20.sp, // Reduced font size
                                      height: 1.2,
                                    ),
                                  ),
                                  Text(
                                    minutes,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: CustomColor.textBlueColor,
                                      fontSize: 20.sp, // Reduced font size
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              
                              Text(
                                
                                currentDay,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: CustomColor.textBlueColor,
                                  fontSize: 20.sp,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/weather/humidity.png",
                                height: 0.07.sh,
                                width: 0.11.sh,
                              ),
                              SizedBox(
                                height: 0.01.sh,
                              ),
                              Text(
                                "${weatherController.weatherModel.value.main?.humidity ?? 00}%",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: CustomColor.textBlueColor,
                                  fontSize: 18.sp, // Reduced font size
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                "HUMIDITY",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: CustomColor.textBlueColor,
                                  fontSize: 12.sp,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/weather/airQuality.png",
                                height: 0.07.sh,
                                width: 0.11.sh,
                              ),
                              SizedBox(
                                height: 0.01.sh,
                              ),
                              Text(
                                "24%",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: CustomColor.textBlueColor,
                                  fontSize: 18.sp, // Reduced font size
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                "AIR POLLUTION",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: CustomColor.textBlueColor,
                                  fontSize: 12.sp,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30,),
                 const RunningLines()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ) // Add your default or mobile screen widget here
// Add your default or mobile screen widget here
      : Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.r)),
              border: Border.all(width: 2, color: CustomColor.lightgreyColor),
              gradient: const LinearGradient(
                colors: [CustomColor.darkgreyColor, CustomColor.lightgreyColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(UIPage());
                        },
                          child: Image(image: AssetImage("assets/remote control.png"),height: 40,width: 40,)),
                      Gap(5),
                      Obx(() => Image.asset(
                            weatherController.conditionImage.value,
                            height: 0.1.sh,
                            width: 0.1.sh,
                          )),
                      Obx(
                        () => Text(
                          weatherController.weatherModel.value.main == null
                              ? ""
                              : weatherController.weatherModel.value.weather![0].main!,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: CustomColor.textBlueColor,
                            fontSize: 20.sp,
                            height: 0,
                          ),
                        ),
                      ),
                      ClockButton(),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Obx(
                        () => Text(
                          weatherController.weatherModel.value.main == null
                              ? "00°"
                              : "${weatherController.weatherModel.value.main!.temp!
                                  .toInt()}°",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: CustomColor.textBlueColor,
                            fontSize: 90.sp,
                            height: 0,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "$hours",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: CustomColor.textBlueColor,
                                  fontSize: 30.sp,
                                  height: 0.8,
                                ),
                              ),
                              Text(
                                ':',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: CustomColor.textBlueColor,
                                  fontSize: 30.sp,
                                  height: 0.8,
                                ),
                              ),
                              Text(
                                minutes,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: CustomColor.textBlueColor,
                                  fontSize: 30.sp,
                                  height: 0.8,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            currentDay,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: CustomColor.textBlueColor,
                              fontSize: 20.sp,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/weather/humidity.png",
                            height: 0.05.sh,
                            width: 0.05.sh,
                          ),
                          SizedBox(
                            height: 0.01.sh,
                          ),
                          Text(
                            "${weatherController.weatherModel.value.main?.humidity ?? 00}%",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: CustomColor.textBlueColor,
                              fontSize: 25.sp,
                              height: 1,
                            ),
                          ),
                          Text(
                            "HUMIDITY",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: CustomColor.textBlueColor,
                              fontSize: 10.sp,
                              height: 1.1,
                            ),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/weather/airQuality.png",
                            height: 0.05.sh,
                            width: 0.05.sh,
                          ),
                          SizedBox(
                            height: 0.01.sh,
                          ),
                          Text(
                            "24%",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: CustomColor.textBlueColor,
                              fontSize: 25.sp,
                              height: 1,
                            ),
                          ),
                          Text(
                            "AIR POLLUTION",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: CustomColor.textBlueColor,
                              fontSize: 10.sp,
                              height: 1.1,
                            ),
                          )
                        ],
                      ),
                      
                    ],
                  ),
                 const SizedBox(height: 30,),
                 const RunningLines()
             //RunningLines(),
                ],
              ),
            ),
          );
  }
}
