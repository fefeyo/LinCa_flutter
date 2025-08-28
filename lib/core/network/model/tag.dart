import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';

part 'tag.g.dart';

@freezed
abstract class Tag with _$Tag {
  const factory Tag({
    @Default('') String id,
    @Default('') String name,
    @Default('') String slug,
    @Default('') String category,
    @Default(false) bool active,
    @Default(0) int order,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}
