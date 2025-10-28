import 'package:freezed_annotation/freezed_annotation.dart';

part 'group.freezed.dart';

part 'group.g.dart';

@freezed
abstract class Group with _$Group {
  const factory Group({
    @Default('') String id,
    @Default('') String name,
    @Default('') String slug,
    @Default('') String color,
    @Default(false) bool active,
    @Default('') String seriesTag,
    @Default(0) int order,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}
