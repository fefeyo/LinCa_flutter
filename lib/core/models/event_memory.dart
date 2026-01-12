import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_memory.freezed.dart';

part 'event_memory.g.dart';

@freezed
abstract class EventMemory with _$EventMemory {
  const factory EventMemory({
    @Default('') String url,
    @Default('') String path,
  }) = _EventMemory;

  factory EventMemory.fromJson(Map<String, dynamic> json) =>
      _$EventMemoryFromJson(json);
}
