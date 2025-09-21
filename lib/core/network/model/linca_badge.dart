import 'package:freezed_annotation/freezed_annotation.dart';

part 'linca_badge.freezed.dart';

part 'linca_badge.g.dart';

@freezed
abstract class LincaBadge with _$LincaBadge {
  const factory LincaBadge({
    @Default('') String id,
    @Default('') String name,
    @Default('') String slug,
    @Default('') String iconUrl,
    @Default('') String description,
    @Default('') String category,
    @Default(false) bool active,
    @Default(0) int order,
  }) = _LincaBadge;

  factory LincaBadge.fromJson(Map<String, dynamic> json) =>
      _$LincaBadgeFromJson(json);
}
