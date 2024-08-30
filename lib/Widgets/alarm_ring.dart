import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class AlarmRingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingScreen({super.key, required this.alarmSettings});

  @override
   createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  @override
  void initState() {
    super.initState();
    playAlarmSound();
  }

void playAlarmSound() {
  if (widget.alarmSettings.volume != null &&
      widget.alarmSettings.volume! > 0) {
    FlutterRingtonePlayer().play(
      android: AndroidSounds.alarm,
      ios: IosSounds.alarm,
      looping: true, // or false if you want to play it once
      volume: widget.alarmSettings.volume!,
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "Your alarm is ringing...",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.white),
            ),
            const RippleAnimation(
              color: Colors.black,
              delay: Duration(milliseconds: 300),
              repeat: true,
              minRadius: 75,
              ripplesCount: 6,
              duration: Duration(milliseconds: 6 * 300),
              child: Text("🔔", style: TextStyle(fontSize: 50)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RawMaterialButton(
                  onPressed: () {
                    final now = DateTime.now();
                    Alarm.set(
                      alarmSettings: widget.alarmSettings.copyWith(
                        dateTime: DateTime(
                          now.year,
                          now.month,
                          now.day,
                          now.hour,
                          now.minute,
                          0,
                          0,
                        ).add(const Duration(minutes: 1)),
                      ),
                    ).then((_) => Navigator.pop(context));
                  },
                  child: Text(
                    "Snooze",
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.white),
                  ),
                ),
                RawMaterialButton(
                  onPressed: () {
                    Alarm.stop(widget.alarmSettings.id)
                        .then((_) => Navigator.pop(context));
                    FlutterRingtonePlayer().stop();
                  },
                  child: Text(
                    "Stop",
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
