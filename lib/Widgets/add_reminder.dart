import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  _AddReminderScreenState createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  DateTime _selectedDate = DateTime.now();
  int _reminderTime = 0; // Time to remind before the event in minutes
  bool? _repeat = false; // Repeat reminder
  bool _isTimeSelected = false;
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime? _calculatedReminderTime;
  final stt.SpeechToText speech = stt.SpeechToText();

  final TextEditingController remindMeToController = TextEditingController();
  final TextEditingController shortNoteController = TextEditingController();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); 

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _calculateReminderTime();
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _isTimeSelected = true;
        _calculateReminderTime();
      });
    }
  }

  void _calculateReminderTime() {
    DateTime selectedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    _calculatedReminderTime =
        selectedDateTime.subtract(Duration(minutes: _reminderTime));
  }

  Future<void> _scheduleReminder() async {
    _calculateReminderTime();

    if (_calculatedReminderTime != null) {
      Duration difference = _calculatedReminderTime!.difference(DateTime.now());
      if (difference.inMilliseconds > 0) {
        String remindMeTo = remindMeToController.text;
        String shortNote = shortNoteController.text;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('reminder_title', remindMeTo);
        await prefs.setString('reminder_note', shortNote);
        await prefs.setInt('reminder_time', _reminderTime);
        await prefs.setInt('reminder_year', _selectedDate.year);
        await prefs.setInt('reminder_month', _selectedDate.month);
        await prefs.setInt('reminder_day', _selectedDate.day);
        await prefs.setInt('reminder_hour', _selectedTime.hour);
        await prefs.setInt('reminder_minute', _selectedTime.minute);

        Future.delayed(difference, () async {
          await flutterLocalNotificationsPlugin.show(
            0,
            'Reminder',
            '$remindMeTo\n\n$shortNote',
            NotificationDetails(
              android: AndroidNotificationDetails(
                'your_channel_id',
                'MATCH Time',
                channelDescription: 'GO watch the ',
                importance: Importance.high,
                priority: Priority.high,
                vibrationPattern: Int64List.fromList([1000, 1000, 5000, 2000]),
              ),
            ),
          );
        });
      } else {
        if (kDebugMode) {
          print('Reminder time is in the past');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Add Reminder',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextButton(
                onPressed: () async {
                  await _scheduleReminder();
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: remindMeToController,
                            decoration: const InputDecoration(
                              hintText: '  Remind me to....',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 20,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.mic,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Tap on the microphone icon on your keyboard to enable voice input'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: shortNoteController,
                            decoration: const InputDecoration(
                              hintText: '  Write Short Note',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 20,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.mic,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Tap on the microphone icon on your keyboard to enable voice input'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                    const SizedBox(height: 16),
                    // Row 3

                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.calendar_today,
                            color: Colors.black,
                          ),
                          onPressed: () => _selectDate(context),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                DateFormat('EEEE, MMM d, yyyy')
                                    .format(_selectedDate),
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            // Reset the date
                            setState(() {
                              _selectedDate = DateTime.now();
                            });
                          },
                        ),
                      ],
                    ),

                    const Divider(thickness: 2),
                    const SizedBox(height: 16),
                    // Row 4
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.alarm,
                            color: Colors.black,
                            size: 30,
                          ),
                          onPressed: () => _selectTime(context),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                _isTimeSelected
                                    ? _selectedTime.format(context)
                                    : 'Select time',
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            // Add your onPressed code here!
                          },
                        ),
                        const Text(
                          'Add More Time',
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            // Reset the time
                            setState(() {
                              _selectedTime = TimeOfDay.now();
                            });
                          },
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                    const SizedBox(height: 16),
                    // Row 5
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.access_alarm_rounded,
                          color: Colors.black,
                          size: 30,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Remind me before',
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                        const Spacer(), // Add Spacer to push the arrow icon to the right
                        GestureDetector(
                          onTap: () {
                            _showReminderDialog(context);
                          },
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                    const SizedBox(height: 20),
                    // Row 6
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.sync_alt_outlined,
                          color: Colors.black,
                          size: 30,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Repeat : ${_repeat ?? false ? 'On' : 'Off'}',
                          style: const TextStyle(
                              fontSize: 20, color: Colors.black),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            _showRepeatDialog(context);
                          },
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  ],
                ))));
  }

  void _showReminderDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Select Reminder Time',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Enter the time before which you want to be reminded (in minutes)'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Minutes',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _reminderTime = int.parse(controller.text);
                    _calculateReminderTime(); // Call _calculateReminderTime after the reminder time is set
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showRepeatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Repeat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('On'),
                leading: Radio(
                  value: true,
                  groupValue: _repeat,
                  onChanged: (value) {
                    setState(() {
                      _repeat = value ??
                          false; // Provide a default value of false if value is null
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: const Text('Off'),
                leading: Radio(
                  value: false,
                  groupValue: _repeat,
                  onChanged: (value) {
                    setState(() {
                      _repeat = value ??
                          false; // Provide a default value of false if value is null
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
