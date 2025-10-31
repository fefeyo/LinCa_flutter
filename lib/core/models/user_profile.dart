import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linca_otaku_support/core/models/favorite_badges.dart';
import 'package:linca_otaku_support/core/network/model/user.dart';

import '../network/model/group.dart';

part 'user_profile.freezed.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    @Default(User()) User user,
    @Default(<Group>[]) List<Group> favoriteGroups,
    @Default(FavoriteBadges()) FavoriteBadges favoriteBadges,
  }) = _UserProfile;
}
