import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class AlarmEditScreen extends StatefulWidget {
  final AlarmSettings? alarmSettings;

  const AlarmEditScreen({super.key, this.alarmSettings});

  @override
  State<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

DateTime selectedDateTime = DateTime.now();

class _AlarmEditScreenState extends State<AlarmEditScreen> {
  bool loading = false;
  bool volumeButtonOn = false;

  late bool creating;
  late bool loopAudio;
  late bool vibrate;
  late double? volume;
  late String assetAudio;
  int hour = 0;
  int minute = 0;
  String amPm = 'AM';
  FixedExtentScrollController _minuteController = FixedExtentScrollController();
  FixedExtentScrollController _hourController = FixedExtentScrollController();
  FixedExtentScrollController _ampmController = FixedExtentScrollController();

  @override
  void initState() {
    super.initState();
    creating = widget.alarmSettings == null;

    if (creating) {
      selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
      selectedDateTime = selectedDateTime.copyWith(second: 0, millisecond: 0);
      loopAudio = true;
      vibrate = true;
      volume = null;
      assetAudio = 'assets/audio/marimba.mp3';
    } else {
      selectedDateTime = widget.alarmSettings!.dateTime;
      loopAudio = widget.alarmSettings!.loopAudio;
      vibrate = widget.alarmSettings!.vibrate;
      volume = widget.alarmSettings!.volume;
      assetAudio = widget.alarmSettings!.assetAudioPath;
    }
    hour = selectedDateTime.hour % 12;
    if (hour == 0) hour = 12; // handle midnight and noon
    minute = selectedDateTime.minute;
    amPm = selectedDateTime.hour >= 12 ? 'PM' : 'AM';

    _minuteController = FixedExtentScrollController(initialItem: selectedDateTime.minute);
    _hourController = FixedExtentScrollController(initialItem: hour - 1);
    _ampmController = FixedExtentScrollController(initialItem: amPm == 'AM' ? 0 : 1);

    // Update the time initially to sync with pickers
    _time();
  }

  String getDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = selectedDateTime.difference(today).inDays;

    switch (difference) {
      case 0:
        return 'Today - ${DateFormat('EEE, d MMM').format(selectedDateTime)}';
      case 1:
        return 'Tomorrow - ${DateFormat('EEE, d MMM').format(selectedDateTime)}';
      default:
        return DateFormat('EEE, d MMM').format(selectedDateTime);
    }
  }

  Future<void> pickTime() async {
    final res = await showTimePicker(
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      context: context,
    );

    if (res != null) {
      setState(() {
        final DateTime now = DateTime.now();
        selectedDateTime = now.copyWith(
            hour: res.hour,
            minute: res.minute,
            second: 0,
            millisecond: 0,
            microsecond: 0);
        if (selectedDateTime.isBefore(now)) {
          selectedDateTime = selectedDateTime.add(const Duration(days: 1));
        }
      });
    }
  }

  AlarmSettings buildAlarmSettings() {
    final id = creating
        ? DateTime.now().millisecondsSinceEpoch % 10000
        : widget.alarmSettings!.id;

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: selectedDateTime,
      loopAudio: loopAudio,
      vibrate: vibrate,
      volume: volumeButtonOn ? 0.5 : 0,
      assetAudioPath: assetAudio,
      notificationTitle: 'Alarm example',
      notificationBody: 'Your alarm ($id) is ringing',
    );
    return alarmSettings;
  }

  void saveAlarm() {
    if (loading) return;
    setState(() => loading = true);
    Alarm.set(alarmSettings: buildAlarmSettings()).then((res) {
      if (res) Navigator.pop(context, true);
      setState(() => loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Flexible(
            flex: 1,
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: CupertinoPicker(
                    squeeze: 0.8,
                    diameterRatio: 5,
                    useMagnifier: true,
                    looping: true,
                    itemExtent: 100,
                    scrollController: _hourController,
                    selectionOverlay:
                        const CupertinoPickerDefaultSelectionOverlay(
                      background: Colors.transparent,
                      capEndEdge: true,
                    ),
                    onSelectedItemChanged: (value) {
                      setState(() {
                        hour = value + 1;
                      });
                      _time();
                    },
                    children: [
                      for (int i = 1; i <= 12; i++) ...[
                        Center(
                          child: Text(
                            '$i',
                            style: const TextStyle(
                                fontSize: 40, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Text(
                  ":",
                  style: TextStyle(fontSize: 40, color: Colors.white),
                ),
                Flexible(
                  flex: 1,
                  child: CupertinoPicker(
                    squeeze: 0.8,
                    diameterRatio: 5,
                    looping: true,
                    itemExtent: 100,
                    scrollController: _minuteController,
                    selectionOverlay:
                        const CupertinoPickerDefaultSelectionOverlay(
                      background: Colors.transparent,
                      capEndEdge: true,
                    ),
                    onSelectedItemChanged: (value) {
                      setState(() {
                        minute = value;
                      });
                      _time();
                    },
                    children: [
                      for (int i = 0; i <= 59; i++) ...[
                        Center(
                          child: Text(
                            i.toString().padLeft(2, '0'),
                            style: const TextStyle(
                                fontSize: 40, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: CupertinoPicker(
                    squeeze: 1,
                    diameterRatio: 15,
                    useMagnifier: true,
                    itemExtent: 100,
                    scrollController: _ampmController,
                    selectionOverlay:
                        const CupertinoPickerDefaultSelectionOverlay(
                      background: Color.fromARGB(0, 185, 182, 182),
                    ),
                    onSelectedItemChanged: (value) {
                      setState(() {
                        amPm = value == 0 ? "AM" : "PM";
                      });
                      _time();
                    },
                    children: [
                      for (var i in ['AM', 'PM']) ...[
                        Center(
                          child: Text(
                            i,
                            style: const TextStyle(
                                fontSize: 25, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(getDay()),
                      trailing: IconButton(
                          onPressed: () => _selectDate(context),
                          icon: const Icon(Icons.calendar_month_outlined)),
                    ),
                    ListTile(
                      title: const Text("Alarm Sound"),
                      trailing: DropdownButton(
                        value: assetAudio,
                        items: const [
                          DropdownMenuItem<String>(
                            value: 'assets/audio/marimba.mp3',
                            child: Text('Marimba'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'assets/audio/nokia.mp3',
                            child: Text('Nokia'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'assets/audio/mozart.mp3',
                            child: Text('Mozart'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'assets/audio/star_wars.mp3',
                            child: Text('Star Wars'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'assets/one_piece.mp3',
                            child: Text('One Piece'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => assetAudio = value!),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Divider(),
                    ),
                    ListTile(
                      title: const Text("Vibration"),
                      trailing: Switch(
                          inactiveThumbColor: null,
                          value: vibrate,
                          onChanged: (value) =>
                              setState(() => vibrate = value)),
                    ),
                    ListTile(
                      title: const Text("Loop alarm audio"),
                      trailing: Switch(
                          inactiveThumbColor: null,
                          value: loopAudio,
                          onChanged: (value) =>
                              setState(() => loopAudio = value)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Divider(),
                    ),
                    ListTile(
                      title: const Text("Volume level"),
                      trailing: Switch(
                        value: volume != null,
                        onChanged: (value) {
                          setState(() {
                            if (value) {
                              volume = 0.5; // Set volume to 0.5 when switch is toggled on
                            } else {
                              volume = null; // Set volume to null when switch is toggled off
                            }
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: volume != null
                          ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    volume! > 0.7
                                        ? Icons.volume_up_rounded
                                        : volume! > 0.1
                                            ? Icons.volume_down_rounded
                                            : Icons.volume_mute_rounded,
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: volume!,
                                      onChanged: (value) {
                                        setState(() => volume = value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                    ),
                    const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
                ),
              ),
              SizedBox(
                child: ElevatedButton(
                  onPressed: saveAlarm,
                  child: const Text(
                    "Save", style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _time() {
    // Convert hour to 24-hour format
    int hour24 = hour % 12 + (amPm == 'PM' ? 12 : 0);

    // Construct a DateTime object with the selected time
    DateTime now = DateTime.now();
    DateTime dateTime = DateTime(
      selectedDateTime.year,
      selectedDateTime.month,
      selectedDateTime.day,
      hour24,
      minute,
    );

    // Check if the selectedDateTime is before the current time
    if (dateTime.isBefore(now)) {
      // If so, add one day to ensure it's a future alarm
      dateTime = dateTime.add(const Duration(days: 1));
    }

    // Update the selectedDateTime with the new DateTime object
    setState(() {
      selectedDateTime = dateTime;
      getDay();
    });
  }

  DateTime convertStringToDateTime(String timeString) {
    // Split the timeString into hours, minutes, and AM/PM parts
    List<String> parts = timeString.split(' ');
    List<String> timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    bool isPM = parts[1].toLowerCase() == 'pm';

    // Adjust the hour if it's PM and not already 12 (e.g., 1 PM becomes 13)
    if (isPM && hour < 12) {
      hour += 12;
    }

    // Assuming you want to set the date part to today
    DateTime today = DateTime.now();

    // Create the DateTime object with the adjusted hour and minute
    DateTime dateTime = DateTime(
      today.year,
      today.month,
      today.day,
      hour,
      minute,
    );

    return dateTime;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? now = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        currentDate: selectedDateTime,
        lastDate: DateTime(2099, 12, 31));

    if (now != null) {
      setState(() {
        selectedDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          selectedDateTime.hour,
          selectedDateTime.minute,
        ); // replace selectedDateTime with now and maintain the time
        if (selectedDateTime.isBefore(DateTime.now())) {
          selectedDateTime = selectedDateTime.add(const Duration(days: 1));
        }
        getDay();
      });
    }
  }
}