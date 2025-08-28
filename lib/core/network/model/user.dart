import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    @Default('') String id,
    @Default('') String displayName,
    @Default('') String photoUrl,
    @Default('') String bio,
    @Default(<String>[]) List<String> artistIds,
    @Default(<String>[]) List<String> badgeIds,
    @Default(<String, String>{}) Map<String, String> links,
    @Default(null) DateTime? createdAt,
    @Default(null) DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
