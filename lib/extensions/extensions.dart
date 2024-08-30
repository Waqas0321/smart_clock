
import 'package:smart_clock/Models/alarm_model.dart';

extension DateTimeExt on DateTime {
  DateTime add({required int years, required int months, required int days, required int hours, required int minutes}) {
    return DateTime(year, month + months, day + days, hour + hours, minute + minutes);
  }
}

extension AlarmModelExt on AlarmModel {
  AlarmModel copyWith({int? id, int? milliseconds, String? dateTime, String? label, String? when, bool? check}) {
    return AlarmModel(
      id: id ?? this.id,
      milliseconds: milliseconds ?? this.milliseconds,
      dateTime: dateTime ?? this.dateTime,
      label: label ?? this.label,
      when: when ?? this.when,
      check: check ?? this.check,
    );
  }
}
/*extension TimeOfDayExt on TimeOfDay {
  String format(BuildContext context) {
    return '${hour}:${minute < 10 ? '0$minute' : minute}:${second < 10 ? '0$second' : second} ${period.name}';
  }
}*/
