import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linca_otaku_support/core/models/favorite_badges.dart';
import 'package:linca_otaku_support/core/network/model/user.dart';

import '../network/model/group.dart';
import '../network/model/linca_badge.dart';

part 'linca_user.freezed.dart';

@freezed
abstract class LincaUser with _$LincaUser {
  const factory LincaUser({
    @Default(User()) User user,
    @Default(<Group>[]) List<Group> favoriteGroups,
    @Default(FavoriteBadges()) FavoriteBadges favoriteBadges,
    @Default(<LincaBadge>[]) List<LincaBadge> acquiredBadges,
    @Default(<User>[]) List<User> friends,
  }) = _LincaUser;
}
