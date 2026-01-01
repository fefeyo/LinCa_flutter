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
      unawaited(_refreshInBackground(badges));
    } else {
      badges.addAll(await badgeRepository.fetch());
    }

    return badges;
  }

  Future<void> _refreshInBackground(List<LincaBadge> current) async {
    final List<LincaBadge> fetched =
        await badgeRepository.fetch(); // 差分 or 全件

    badgeRepository.refreshInBackground(
      current: current,
      updated: fetched,
      getId: (LincaBadge badge) => badge.id,
      onChanged: (List<LincaBadge> merged) {
        state = AsyncValue<List<LincaBadge>>.data(merged);
      },
    );
  }
}
