  import 'dart:async';
   import 'package:alarm/alarm.dart';
import 'package:flutter/foundation.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_slidable/flutter_slidable.dart';
  import 'package:permission_handler/permission_handler.dart';
  import 'package:intl/intl.dart';
  import 'package:smart_clock/Widgets/alarm_edit.dart';
  import 'package:smart_clock/Widgets/alarm_ring.dart';

  class AlarmHomeScreen extends StatefulWidget {
    const AlarmHomeScreen({super.key});

    @override
    State<AlarmHomeScreen> createState() => _AlarmHomeScreenState();
  }

  class _AlarmHomeScreenState extends State<AlarmHomeScreen> {
    late List<AlarmSettings> alarms;
    final List<bool> _alarmOnOff = [];
    static StreamSubscription<AlarmSettings>? subscription;

  @override
  void initState() {
    super.initState(); // Initialize the state of the parent class

    // Check and request notification permissions if the platform is Android
    if (Alarm.android) {
      checkAndroidNotificationPermission();
    }

    // Load the list of alarms
    

    // Subscribe to the alarm ring stream if not already subscribed
    // Subscribe to the alarm ring stream if not already subscribed
  subscription ??= Alarm.ringStream.stream.listen(
      (alarmSettings) {
        if (kDebugMode) {
          print("Alarm triggered: ${alarmSettings.id}");
        } // Debug statement
        navigateToRingScreen(alarmSettings); // Navigate to the alarm ringing screen
      },
    );
  loadAlarms();

  }


    void loadAlarms() {
      setState(() {
        alarms = Alarm.getAlarms();
        for (int i = 0; i < alarms.length; i++) {
          if (alarms[i].dateTime.year == 2050) {
            _alarmOnOff.add(false);
          } else {
            _alarmOnOff.add(true);
          }
        }
        alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
      });
    }

Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
  await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AlarmRingScreen(
            alarmSettings: alarmSettings,
          ),
        ),
      );

     setState(() {
    // Reload the alarms after navigating back
    loadAlarms();
  });
    }

    Future<void> navigateToAlarmScreen(AlarmSettings? settings) async {
      final res = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AlarmEditScreen(
            alarmSettings: settings,
          ),
        ),
      );

      if (res != null && res == true) loadAlarms();
    }

    Future<void> checkAndroidNotificationPermission() async {
      final status = await Permission.notification.status;
      if (status.isDenied) {
       // final res = await Permission.notification.request();
      }
    }

    Future<void> checkAndroidExternalStoragePermission() async {
      final status = await Permission.storage.status;
      if (status.isDenied) {
        //final res = await Permission.storage.request();
      }
    }

    @override
    void dispose() {
      subscription?.cancel();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Center(child: Realtime()),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => navigateToAlarmScreen(null),
                    icon: const Icon(Icons.add_alarm_rounded,color: Colors.white,size: 50,),
                  ),
                ],
              ),
              alarms.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: alarms.length,
                        itemBuilder: (context, index) {
                          return _buildAlarmCard(alarms[index], index);
                        },
                      ),
                    )
                  : Expanded(
                      child: Center(
                        child: Text(
                          "No alarms set",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontSize: 25,
                              ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      );
    }

    List<String> _hour(TimeOfDay time) {
      int hour = 0;
      String ampm = 'am';
      if (time.hour > 12) {
        hour = time.hour - 12;
        ampm = 'pm';
      } else if (time.hour == 0) {
        hour = 12;
      } else {
        hour = time.hour;
        ampm = 'am';
      }

      return [hour.toString().padLeft(2, '0'), ampm];
    }

    Widget _buildAlarmCard(AlarmSettings alarm, int index) {
      TimeOfDay time = TimeOfDay.fromDateTime(alarm.dateTime);
      String formattedDate = DateFormat('EEE, d MMM').format(alarm.dateTime);
      return GestureDetector(
        onTap: () => navigateToAlarmScreen(alarms[index]),
        child: Slidable(
          closeOnScroll: true,
          endActionPane: ActionPane(
            extentRatio: 0.4,
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                borderRadius: BorderRadius.circular(12),
                onPressed: (context) {
                  Alarm.stop(alarm.id);
                  loadAlarms();
                },
                icon: Icons.delete_forever,
                backgroundColor: Colors.red.shade700,
              ),
            ],
          ),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(""),
                ListTile(
                  splashColor: null,
                  dense: true,
                  minVerticalPadding: 10,
                  horizontalTitleGap: 10,
                  enabled: false,
                  title: Row(
                    children: [
                      Text(
                        "${_hour(time)[0]}:${time.minute.toString().padLeft(2, '0')} ",
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.start,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(_hour(time)[1]),
                      ),
                      const Expanded(child: Text("")),
                      Text(formattedDate.toString()),
                    ],
                  ),
                  trailing: Switch(
                    value: _alarmOnOff[index],
                    onChanged: (bool value) {
                      if (value == false) {
                        Alarm.set(
                          alarmSettings: alarm.copyWith(
                            dateTime: alarm.dateTime.copyWith(year: 2050),
                          ),
                        );
                      } else {
                        Alarm.set(
                          alarmSettings: alarm.copyWith(
                            dateTime: alarm.dateTime.copyWith(year: DateTime.now().year),
                          ),
                        );
                      }
                      setState(() {
                        _alarmOnOff[index] = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    }
  }

  class Realtime extends StatefulWidget {
    const Realtime({super.key});

    @override
     createState() => _RealtimeState();
  }

  class _RealtimeState extends State<Realtime> {
    late StreamController<DateTime> _clockStreamController;
    late DateTime _currentTime;
late Timer _timer;
    @override
    void initState() {
      super.initState();
      _currentTime = DateTime.now();
      _clockStreamController = StreamController<DateTime>();
      _startClock();
    }
 
    void _startClock() {
      _timer =
      Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        _currentTime = DateTime.now();
        _clockStreamController.add(_currentTime);
      });
    }

    @override
    void dispose() {
      _clockStreamController.close();
      _timer.cancel();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return StreamBuilder<DateTime>(
        stream: _clockStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            String formattedTime = DateFormat('hh:mm:ss a').format(snapshot.data!);
            return Text(
              formattedTime,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white),
            );
          } else {
            return Text(
              "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white),
            );
          }
        },
      );
    }
  }