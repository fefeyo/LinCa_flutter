import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linca_otaku_support/core/network/model/linca_badge.dart';

part 'favorite_badges.freezed.dart';

@freezed
abstract class FavoriteBadges with _$FavoriteBadges {
  const factory FavoriteBadges({
    LincaBadge? badge01,
    LincaBadge? badge02,
    LincaBadge? badge03,
  }) = _FavoriteBadges;
}
