import 'dart:async';

import 'package:linca_otaku_support/core/network/controller/linca_controller.dart';

import '../model/linca_badge.dart';
import '../providers.dart';
import '../repository/badge_repository.dart';

class BadgeController extends LincaController<List<LincaBadge>> {
  late BadgeRepository badgeRepository;

  @override
  FutureOr<List<LincaBadge>> buildImpl() async {
    badgeRepository = ref.read(badgeRepositoryProvider);
    return badgeRepository.getLatest(
      getId: (LincaBadge badge) => badge.id,
    );
  }
}
