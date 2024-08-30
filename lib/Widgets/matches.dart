import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_clock/Widgets/alarm_ring.dart';
import 'package:smart_clock/utils/Colors.dart';

import '../Controller/matches_controller.dart';
import '../Controller/player_matches_controller.dart';
import '../View/edit_screen.dart';
import 'add_reminder.dart';

class Matches extends StatefulWidget {
  final String screen;
  const Matches({super.key, required this.screen});

  @override
  State<Matches> createState() => _MatchesState();
}

class _MatchesState extends State<Matches> {
  MatchesController matchesController = Get.put(MatchesController());
  PlayerMatchesController playerMatchesController =
      Get.put(PlayerMatchesController());

  late List<AlarmSettings> alarms;
  static StreamSubscription<AlarmSettings>? subscription;

  @override
  void initState() {
    super.initState();
    //if (Alarm.android) {
    //checkAndroidNotificationPermission();
    //checkAndroidScheduleExactAlarmPermission();
    //}
    /*  loadAlarms();
    subscription ??= Alarm.ringStream.stream.listen(
          (alarmSettings) => navigateToRingScreen(alarmSettings),
    );*/
  }

  void loadAlarms() {
    setState(() {
      alarms = Alarm.getAlarms();
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    });
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmRingScreen(alarmSettings: alarmSettings),
      ),
    );
    loadAlarms();
  }

  Future<void> navigateToAlarmScreen(
      AlarmSettings? settings, DateTime time, String? title) async {
    final res = await showModalBottomSheet<bool?>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.75,
            child: AlarmEditScreen(
              alarmSettings: settings,
              time: time,
              title: title ?? '-',
            ),
          );
        });

    if (res != null && res == true) loadAlarms();
  }

  Future<void> checkAndroidNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      alarmPrint('Requesting notification permission...');
      final res = await Permission.notification.request();
      alarmPrint(
        'Notification permission ${res.isGranted ? '' : 'not '}granted.',
      );
    }
  }

  Future<void> checkAndroidExternalStoragePermission() async {
    final status = await Permission.storage.status;
    if (status.isDenied) {
      alarmPrint('Requesting external storage permission...');
      final res = await Permission.storage.request();
      alarmPrint(
        'External storage permission ${res.isGranted ? '' : 'not'} granted.',
      );
    }
  }

  Future<void> checkAndroidScheduleExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    alarmPrint('Schedule exact alarm permission: $status.');
    if (status.isDenied) {
      alarmPrint('Requesting schedule exact alarm permission...');
      final res = await Permission.scheduleExactAlarm.request();
      alarmPrint(
        'Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted.',
      );
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    matchesController.getMatches();
    playerMatchesController.getMatches();
    return widget.screen == "tablet"
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: (orientation == Orientation.portrait) ? 0.7.sh : 0.54.sh,
              decoration: CustomColor.boxDecoration,
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          "MATCHES",
                          style: GoogleFonts.bebasNeue(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 30,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Obx(() {
                          // Using a List to store matches along with isPlayerMatch flag
                          var matchesWithFlags = <Map<String, dynamic>>[];

                          // Adding player matches with flag
                          var playerMatches = playerMatchesController
                                  .playersModel.value.searchResult ??
                              [];
                          for (var match in playerMatches) {
                            matchesWithFlags.add({
                              'match': match,
                              'isPlayerMatch': true,
                            });
                          }

                          // Adding regular matches with flag
                          var regularMatches = matchesController
                                  .matchesModel.value.searchResult ??
                              [];
                          for (var match in regularMatches) {
                            matchesWithFlags.add({
                              'match': match,
                              'isPlayerMatch': false,
                            });
                          }

                          // Sort matches by datetime
                          matchesWithFlags.sort((a, b) {
                            DateTime datetimeA =
                                DateFormat("EEEE, MM/dd/yyyy - hh:mm a Z")
                                    .parse(
                              a['match'].upcomingMatch?.time ??
                                  "Sunday, 00/00/0000 - 00:00 AM +0700",
                            );
                            DateTime datetimeB =
                                DateFormat("EEEE, MM/dd/yyyy - hh:mm a Z")
                                    .parse(
                              b['match'].upcomingMatch?.time ??
                                  "Sunday, 00/00/0000 - 00:00 AM +0700",
                            );
                            DateTime now = DateTime.now();
                            int differenceA =
                                datetimeA.difference(now).inMilliseconds.abs();
                            int differenceB =
                                datetimeB.difference(now).inMilliseconds.abs();
                            return differenceA.compareTo(differenceB);
                          });

                          return matchesWithFlags.isNotEmpty
                              ? ListView.builder(
                                  itemCount: matchesWithFlags.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    var matchData = matchesWithFlags[index];
                                    var match = matchData['match'];
                                    var isPlayerMatch =
                                        matchData['isPlayerMatch'];
                                    DateTime datetime = DateFormat(
                                            "EEEE, MM/dd/yyyy - hh:mm a Z")
                                        .parse(
                                      match.upcomingMatch?.time ??
                                          "Sunday, 00/00/0000 - 00:00 AM +0700",
                                    );
                                    String date =
                                        DateFormat("hh:mm a Z", 'en_US')
                                            .format(datetime)
                                            .replaceAllMapped(
                                              RegExp(r'(\d+:\d+)'),
                                              (Match m) =>
                                                  m[1]!.padLeft(5, '0'),
                                            );
                                    String time =
                                        DateFormat("EEEE, MM/dd/yyyy", 'en_US')
                                            .format(datetime)
                                            .replaceAllMapped(
                                              RegExp(r'(\d+:\d+)'),
                                              (Match m) =>
                                                  m[1]!.padLeft(5, '0'),
                                            );

                                    return match.upcomingMatch != null
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    width: 2,
                                                    color: CustomColor
                                                        .lightgreyColor),
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    CustomColor.darkgreyColor,
                                                    CustomColor.lightgreyColor,
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Container(
                                                          width: 40,
                                                          height: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50),
                                                            border: Border.all(
                                                                width: 2,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          child: CircleAvatar(
                                                            backgroundImage:
                                                                NetworkImage(
                                                              match
                                                                  .upcomingMatch!
                                                                  .homeImg!,
                                                            ),
                                                          ),
                                                        ),
                                                        Column(
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(Icons
                                                                  .notifications),
                                                              color:
                                                                  Colors.white,
                                                              onPressed: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            const AddReminderScreen(),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                            Text(
                                                              date,
                                                              style: GoogleFonts
                                                                  .bebasNeue(
                                                                fontSize: 24,
                                                                color: CustomColor
                                                                    .textGoldenDarkColor,
                                                              ),
                                                            ),
                                                            Text(
                                                              time,
                                                              style: GoogleFonts
                                                                  .bebasNeue(
                                                                fontSize: 14,
                                                                color: CustomColor
                                                                    .textGoldenDarkColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          width: 40,
                                                          height: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50),
                                                            border: Border.all(
                                                                width: 2,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          child: CircleAvatar(
                                                            backgroundImage:
                                                                NetworkImage(
                                                              match
                                                                  .upcomingMatch!
                                                                  .awayImg!,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          match.upcomingMatch
                                                                  ?.label ??
                                                              "",
                                                          style: GoogleFonts
                                                              .bebasNeue(
                                                            fontSize: 10,
                                                            color: CustomColor
                                                                .textGoldenLightColor,
                                                          ),
                                                          overflow:
                                                              TextOverflow.fade,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          isPlayerMatch
                                                              ? Icons.person
                                                              : Icons.group,
                                                          color: CustomColor
                                                              .textGoldenDarkColor,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox();
                                  },
                                )
                              : Center(
                                  child: Text(
                                    'No matches found.',
                                    style: GoogleFonts.bebasNeue(
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                  ),
                                );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ))
        : Scaffold(
            backgroundColor: CustomColor.backgroundColor,
            body: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        "MATCHES",
                        style: GoogleFonts.bebasNeue(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 30,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Obx(() {
                        // Using a List to store matches along with isPlayerMatch flag
                        var matchesWithFlags = <Map<String, dynamic>>[];

                        // Adding player matches with flag
                        var playerMatches = playerMatchesController
                                .playersModel.value.searchResult ??
                            [];
                        for (var match in playerMatches) {
                          matchesWithFlags.add({
                            'match': match,
                            'isPlayerMatch': true,
                          });
                        }

                        // Adding regular matches with flag
                        var regularMatches =
                            matchesController.matchesModel.value.searchResult ??
                                [];
                        for (var match in regularMatches) {
                          matchesWithFlags.add({
                            'match': match,
                            'isPlayerMatch': false,
                          });
                        }

                        // Sort matches by datetime
                        matchesWithFlags.sort((a, b) {
                          DateTime datetimeA =
                              DateFormat("EEEE, MM/dd/yyyy - hh:mm a Z").parse(
                            a['match'].upcomingMatch?.time ??
                                "Sunday, 00/00/0000 - 00:00 AM +0700",
                          );
                          DateTime datetimeB =
                              DateFormat("EEEE, MM/dd/yyyy - hh:mm a Z").parse(
                            b['match'].upcomingMatch?.time ??
                                "Sunday, 00/00/0000 - 00:00 AM +0700",
                          );
                          DateTime now = DateTime.now();
                          int differenceA =
                              datetimeA.difference(now).inMilliseconds.abs();
                          int differenceB =
                              datetimeB.difference(now).inMilliseconds.abs();
                          return differenceA.compareTo(differenceB);
                        });

                        return matchesWithFlags.isNotEmpty
                            ? ListView.builder(
                                itemCount: matchesWithFlags.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var matchData = matchesWithFlags[index];
                                  var match = matchData['match'];
                                  var isPlayerMatch =
                                      matchData['isPlayerMatch'];
                                  DateTime datetime =
                                      DateFormat("EEEE, MM/dd/yyyy - hh:mm a Z")
                                          .parse(
                                    match.upcomingMatch?.time ??
                                        "Sunday, 00/00/0000 - 00:00 AM +0700",
                                  );
                                  String date = DateFormat("hh:mm a Z", 'en_US')
                                      .format(datetime)
                                      .replaceAllMapped(
                                        RegExp(r'(\d+:\d+)'),
                                        (Match m) => m[1]!.padLeft(5, '0'),
                                      );
                                  String time =
                                      DateFormat("EEEE, MM/dd/yyyy", 'en_US')
                                          .format(datetime)
                                          .replaceAllMapped(
                                            RegExp(r'(\d+:\d+)'),
                                            (Match m) => m[1]!.padLeft(5, '0'),
                                          );

                                  return match.upcomingMatch != null
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  width: 2,
                                                  color: CustomColor
                                                      .lightgreyColor),
                                              gradient: const LinearGradient(
                                                colors: [
                                                  CustomColor.darkgreyColor,
                                                  CustomColor.lightgreyColor,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Container(
                                                        width: 80,
                                                        height: 80,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                          border: Border.all(
                                                              width: 2,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        child: CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(
                                                            match.upcomingMatch!
                                                                .homeImg!,
                                                          ),
                                                        ),
                                                      ),
                                                      Column(
                                                        children: [
                                                          IconButton(
                                                            icon: const Icon(Icons
                                                                .notifications),
                                                            color: Colors.white,
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          const AddReminderScreen(),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          Text(
                                                            date,
                                                            style: GoogleFonts
                                                                .bebasNeue(
                                                              fontSize: 24,
                                                              color: CustomColor
                                                                  .textGoldenDarkColor,
                                                            ),
                                                          ),
                                                          Text(
                                                            time,
                                                            style: GoogleFonts
                                                                .bebasNeue(
                                                              fontSize: 14,
                                                              color: CustomColor
                                                                  .textGoldenDarkColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        width: 80,
                                                        height: 80,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                          border: Border.all(
                                                              width: 2,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        child: CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(
                                                            match.upcomingMatch!
                                                                .awayImg!,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        match.upcomingMatch
                                                                ?.label ??
                                                            "",
                                                        style: GoogleFonts
                                                            .bebasNeue(
                                                          fontSize: 18,
                                                          color: CustomColor
                                                              .textGoldenLightColor,
                                                        ),
                                                        overflow:
                                                            TextOverflow.fade,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        isPlayerMatch
                                                            ? Icons.person
                                                            : Icons.group,
                                                        color: CustomColor
                                                            .textGoldenDarkColor,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox();
                                },
                              )
                            : Center(
                                child: Text(
                                  'No matches found.',
                                  style: GoogleFonts.bebasNeue(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
