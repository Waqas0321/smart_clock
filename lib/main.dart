import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:smart_clock/Controller/custom_matches_controller.dart';
import 'package:smart_clock/Controller/matches_controller.dart';
import 'package:smart_clock/Controller/player_matches_controller.dart';
import 'package:smart_clock/Controller/sports_new_controller.dart';
import 'package:smart_clock/Models/alarm_model.dart';
import 'package:smart_clock/View/splash_screen.dart';
import 'package:smart_clock/utils/Colors.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
  KeepScreenOn.turnOn();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: CustomColor.darkgreyColor, // Set your desired color
    ),
  );
  await Alarm.init(showDebugLogs: true);
  Get.put(AlarmProvider());
  Get.lazyPut(() => AlarmProvider());
  //await AndroidAlarmManager.initialize();
  runApp(const MyApp());
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CustomMatchesController());
    Get.put(PlayerMatchesController());
    Get.put(MatchesController());
    Get.put(
        SportsNewsController()); // Ensure PlayerMatchesController is initialized
    // Other initializations
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // designSize: const Size(360, 690),
      designSize: Size(MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height),
      minTextAdapt: true,
      splitScreenMode: true,
      child: Builder(builder: (context) {
        return GetMaterialApp(
          initialBinding: InitialBinding(),
          theme: ThemeData(
              scaffoldBackgroundColor: CustomColor.darkgreyColor,
              primaryColor: CustomColor.primaryColor,
              indicatorColor: CustomColor.primaryColor,
              hintColor: CustomColor.primaryColor),
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        );
      }),
    );
  }
}
