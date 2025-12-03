import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/network/controller/linca_controller.dart';

import '../model/linca_badge.dart';
import '../providers.dart';
import '../repository/badge_repository.dart';

class BadgeController extends LincaController<List<LincaBadge>> {
  late BadgeRepository badgeRepository;

  @override
  FutureOr<List<LincaBadge>> buildImpl() async {
    badgeRepository = ref.read(badgeRepositoryProvider);
    final List<LincaBadge> badges = await badgeRepository.get();

    if (badges.isNotEmpty) {
      badgeRepository.refreshInBackground(
        current: state.value ?? <LincaBadge>[],
        onChanged: (List<LincaBadge> updatedBadges) {
          state = AsyncValue<List<LincaBadge>>.data(updatedBadges);
        },
      );
    } else {
      badges.addAll(await badgeRepository.fetch());
    }

    return badges;
  }
}
