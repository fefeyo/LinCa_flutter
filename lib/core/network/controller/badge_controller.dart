import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/linca_badge.dart';
import '../providers.dart';
import '../repository/badge_repository.dart';

class BadgeController extends AsyncNotifier<List<LincaBadge>> {
  late BadgeRepository badgeRepository;

  @override
  FutureOr<List<LincaBadge>> build() async {
    badgeRepository = ref.read(badgeRepositoryProvider);

    return badgeRepository.loadBadges();
  }
}
