import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_clock/Widgets/calender.dart';
import 'package:smart_clock/Widgets/clock.dart';
import 'package:smart_clock/Widgets/matches.dart';
import 'package:smart_clock/Widgets/profile.dart';
import 'package:smart_clock/Widgets/sports_news.dart';
import 'package:smart_clock/Widgets/weather.dart';
import 'package:connectivity/connectivity.dart';
import 'Widgets/luner_calender.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _showNoInternetSnackbar();
    }
  }

  void _showNoInternetSnackbar() {
    final snackBar = SnackBar(
      content: const Text('No internet connection'),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          // You can add some action when the user clicks on the "OK" button
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: ScreenUtil().screenWidth > 600
              ? Stack(
                  children: [
                    const Column(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Clock(screen: "tablet"),
                              )),
                              // Container(color: Colors.white, child: CalendarDatePicker(initialDate: DateTime.now(), firstDate: DateTime.utc(2010, 10, 16), lastDate: DateTime.utc(2030, 3, 14) , onDateChanged: (DateTime value) {  },))
                              Expanded(
                                child: Row(
                                  children: [
                                    LunerCalender(screen: "tablet"),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Calender(screen: "tablet"),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              // Clock(),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Weather(screen: "tablet")),
                            Expanded(
                                child: Matches(
                              screen: "tablet",
                            )),
                            Expanded(child: SportNews(screen: "tablet")),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                        right: 20,
                        top: 10,
                        child: GestureDetector(
                            onTap: () => Get.to(() => const Profile(
                                  screen: "tablet",
                                )),
                            child: Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 20.sp,
                            )))
                  ],
                )
              : Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "HOME",
                              style: GoogleFonts.bebasNeue(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontSize: 30.sp,
                                  height: 0),
                            ),
                          ),
                          const Row(
                            children: [
                              Expanded(
                                  child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Clock(screen: "mobile"),
                              )),
                            ],
                          ),
                          const Row(
                            children: [
                              Expanded(
                                  child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Weather(screen: "mobile"),
                              )),
                            ],
                          ),
                          const Row(
                            children: [
                              Expanded(
                                  child: Column(
                                children: [
                                  LunerCalender(screen: "mobile"),
                                  Calender(screen: "mobile"),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        right: 20,
                        top: 10,
                        child: GestureDetector(
                            onTap: () => Get.to(() => const Profile(
                                  screen: "mobile",
                                )),
                            child: Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 20.sp,
                            )))
                  ],
                )),
    );
  }
}
