import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum(alwaysCreate: true)
enum CalendarEventType {
  @JsonValue('holiday')
  holiday,

  @JsonValue('character_birthday')
  characterBirthday,

  @JsonValue('cast_birthday')
  castBirthday,

  @JsonValue('variable_holiday')
  variableHoliday,
}