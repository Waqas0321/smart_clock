import 'package:flutter/material.dart';

class SetMultipleAlarmsScreen extends StatefulWidget {
  final Function(List<TimeOfDay>) onAlarmsSet;

  const SetMultipleAlarmsScreen({super.key, required this.onAlarmsSet});

  @override
   createState() => _SetMultipleAlarmsScreenState();
}

class _SetMultipleAlarmsScreenState extends State<SetMultipleAlarmsScreen> {
  List<TimeOfDay> alarmTimes = [];

  void pickAlarmTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        alarmTimes.add(pickedTime);
      });
    }
  }

  void removeAlarm(int index) {
    setState(() {
      alarmTimes.removeAt(index);
    });
  }

  void saveAlarms() {
    widget.onAlarmsSet(alarmTimes);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Multiple Alarms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveAlarms,
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: pickAlarmTime,
            child: const Text('Add Alarm'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: alarmTimes.length,
              itemBuilder: (context, index) {
                final alarm = alarmTimes[index];
                return ListTile(
                  title: Text(
                    alarm.format(context),
                    style: const TextStyle(fontSize: 20),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => removeAlarm(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
