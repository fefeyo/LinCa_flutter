import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/network/controller/participation_controller.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/network/repository/participation_repository.dart';

import '../auth/providers.dart';
import '../models/linca_event.dart';
import 'controller/badge_controller.dart';
import 'controller/event_controller.dart';
import 'controller/group_controller.dart';
import 'controller/tag_controller.dart';
import 'controller/user_controller.dart';
import 'controller/venue_controller.dart';
import 'model/badge.dart';
import 'model/group.dart';
import 'model/tag.dart';
import 'model/user.dart';
import 'model/venue.dart';
import 'repository/badge_repository.dart';
import 'repository/event_repository.dart';
import 'repository/group_repository.dart';
import 'repository/tag_repository.dart';
import 'repository/user_repository.dart';
import 'repository/venue_repository.dart';

final Provider<UserRepository> userRepositoryProvider =
    Provider<UserRepository>(
  (Ref ref) => UserRepository(ref.watch(fireStoreProvider)),
);

final AsyncNotifierProvider<UserController, User> userControllerProvider =
    AsyncNotifierProvider<UserController, User>(UserController.new);

final Provider<BadgeRepository> badgeRepositoryProvider =
    Provider<BadgeRepository>(
  (Ref ref) => BadgeRepository(ref.watch(fireStoreProvider)),
);

final AsyncNotifierProvider<BadgeController, List<Badge>>
    badgeControllerProvider =
    AsyncNotifierProvider<BadgeController, List<Badge>>(BadgeController.new);

final Provider<EventRepository> eventRepositoryProvider =
    Provider<EventRepository>(
  (Ref ref) => EventRepository(ref.watch(fireStoreProvider)),
);

final AsyncNotifierProvider<EventController, List<LincaEvent>>
    eventControllerProvider =
    AsyncNotifierProvider<EventController, List<LincaEvent>>(
        EventController.new);

final Provider<GroupRepository> groupRepositortyProvider =
    Provider<GroupRepository>(
  (Ref ref) => GroupRepository(ref.watch(fireStoreProvider)),
);

final AsyncNotifierProvider<GroupController, List<Group>>
    groupControllerProvider =
    AsyncNotifierProvider<GroupController, List<Group>>(GroupController.new);

final Provider<TagRepository> tagRepositoryProvider = Provider<TagRepository>(
  (Ref ref) => TagRepository(ref.watch(fireStoreProvider)),
);

final AsyncNotifierProvider<TagController, List<Tag>> tagControllerProvider =
    AsyncNotifierProvider<TagController, List<Tag>>(TagController.new);

final Provider<VenueRepository> venueRepositoryProvider =
    Provider<VenueRepository>(
  (Ref ref) => VenueRepository(ref.watch(fireStoreProvider)),
);

final AsyncNotifierProvider<VenueController, List<Venue>>
    venueControllerProvider =
    AsyncNotifierProvider<VenueController, List<Venue>>(VenueController.new);

final Provider<ParticipationRepository> participationRepositoryProvider =
    Provider<ParticipationRepository>((Ref ref) {
  return ParticipationRepository(ref.watch(fireStoreProvider));
});

final AsyncNotifierProvider<ParticipationController,
        Map<LincaEvent, ParticipationInfo>> participationControllerProvider =
    AsyncNotifierProvider<ParticipationController,
        Map<LincaEvent, ParticipationInfo>>(ParticipationController.new);
