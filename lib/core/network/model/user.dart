import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linca_otaku_support/core/network/model/datetime_timestamp_converter.dart';

part 'user.freezed.dart';

part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    @Default('') String id,
    @Default('幻の学院生') String displayName,
    @Default('') String photoUrl,
    @Default('よろしくお願いします！') String bio,
    @Default(<String>[]) List<String> favoriteGroups,
    @Default(<String>[]) List<String> favoriteBadges,
    @Default(<String, String>{}) Map<String, String> links,
    @DateTimeTimestampConverter() DateTime? createdAt,
    @DateTimeTimestampConverter() DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
