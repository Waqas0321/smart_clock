import 'package:get/get.dart';

class AlarmModel {
  final int? id;
  final int? milliseconds;
  final String? dateTime;
  final String? label;
  final String? when;
  bool? check;
  String sound;

  AlarmModel({this.id, this.milliseconds, this.dateTime, this.label, this.when, this.check, this.sound = 'default',});
}

class AlarmProvider extends GetxController {
  var modelist = [].obs;

  void addAlarm(AlarmModel alarm) {
    modelist.add(alarm);
  }

  void deleteAlarm(int id) {
    modelist.removeWhere((alarm) => alarm.id == id);
  }

  void editAlarm(int index, AlarmModel alarm) {
    modelist[index] = alarm;
  }
  
}
