import 'package:freezed_annotation/freezed_annotation.dart';

part 'badge.freezed.dart';

part 'badge.g.dart';

@freezed
abstract class Badge with _$Badge {
  const factory Badge({
    @Default('') String id,
    @Default('') String name,
    @Default('') String slug,
    @Default('') String iconUrl,
    @Default('') String description,
    @Default('') String category,
    @Default(false) bool active,
    @Default(0) int order,
  }) = _Badge;

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);
}
