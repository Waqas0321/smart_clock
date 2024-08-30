import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:smart_clock/Models/alarm_model.dart';

class AlarmProvider extends GetxController {
  final RxList<AlarmModel> alarms = <AlarmModel>[].obs;

  void addAlarm(AlarmModel alarm) {
    alarms.add(alarm);
  }

  void editAlarm(int index, AlarmModel alarm) {
    alarms[index] = alarm;
  }
}