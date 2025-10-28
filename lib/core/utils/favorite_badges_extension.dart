import 'package:linca_otaku_support/core/models/favorite_badges.dart';
import 'package:linca_otaku_support/core/network/model/linca_badge.dart';

extension FavoriteBadgesExtension on FavoriteBadges {
  List<LincaBadge?> get toList => <LincaBadge?>[
        badge01,
        badge02,
        badge03,
      ];

  List<String> get toSlugList => <String>[
        badge01?.slug ?? '',
        badge02?.slug ?? '',
        badge03?.slug ?? '',
      ];

  FavoriteBadges setBadge({
    required int index,
    LincaBadge? badge,
  }) {
    FavoriteBadges changedFavoriteBadges = copyWith();
    if (badge != null) {
      changedFavoriteBadges = _removeDuplicatedBadge(badge: badge);
    }
    switch (index) {
      case 0:
        changedFavoriteBadges = changedFavoriteBadges.copyWith(badge01: badge);
        break;
      case 1:
        changedFavoriteBadges = changedFavoriteBadges.copyWith(badge02: badge);
        break;
      case 2:
        changedFavoriteBadges = changedFavoriteBadges.copyWith(badge03: badge);
        break;
      default:
        changedFavoriteBadges = copyWith();
    }

    return changedFavoriteBadges;
  }

  bool contains(String slug) {
    return toList.any((LincaBadge? badge) => badge?.slug == slug);
  }

  FavoriteBadges _removeDuplicatedBadge({
    required LincaBadge badge,
  }) {
    return FavoriteBadges(
      badge01: badge01?.slug == badge.slug ? null : badge01,
      badge02: badge02?.slug == badge.slug ? null : badge02,
      badge03: badge03?.slug == badge.slug ? null : badge03,
    );
  }
}
