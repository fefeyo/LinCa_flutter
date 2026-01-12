import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../auth/providers.dart';
import '../models/linca_event.dart';
import '../models/linca_user.dart';
import '../utils/providers.dart';
import 'controller/badge_controller.dart';
import 'controller/event_controller.dart';
import 'controller/friend_controller.dart';
import 'controller/group_controller.dart';
import 'controller/participation_controller.dart';
import 'controller/tag_controller.dart';
import 'controller/user_controller.dart';
import 'controller/user_event_controller.dart';
import 'controller/venue_controller.dart';
import 'model/group.dart';
import 'model/linca_badge.dart';
import 'model/participation_info.dart';
import 'model/tag.dart';
import 'model/venue.dart';
import 'repository/badge_repository.dart';
import 'repository/event_repository.dart';
import 'repository/friend_repository.dart';
import 'repository/group_repository.dart';
import 'repository/participation_repository.dart';
import 'repository/tag_repository.dart';
import 'repository/user_event_repository.dart';
import 'repository/user_repository.dart';
import 'repository/venue_repository.dart';

final Provider<UserRepository> userRepositoryProvider =
    Provider<UserRepository>(
  (Ref ref) => UserRepository(
    uid: ref.watch(uidProvider),
    fireStore: ref.watch(fireStoreProvider),
  ),
);

final AsyncNotifierProvider<UserController, LincaUser> userControllerProvider =
    AsyncNotifierProvider<UserController, LincaUser>(UserController.new);

final Provider<BadgeRepository> badgeRepositoryProvider =
    Provider<BadgeRepository>(
  (Ref ref) => BadgeRepository(
    uid: ref.watch(uidProvider),
    fireStore: ref.watch(fireStoreProvider),
    preferences: ref.watch(preferencesServiceProvider),
  ),
);

final AsyncNotifierProvider<BadgeController, List<LincaBadge>>
    badgeControllerProvider =
    AsyncNotifierProvider<BadgeController, List<LincaBadge>>(
        BadgeController.new);

final Provider<EventRepository> eventRepositoryProvider =
    Provider<EventRepository>(
  (Ref ref) => EventRepository(
    uid: ref.watch(uidProvider),
    fireStore: ref.watch(fireStoreProvider),
    preferences: ref.watch(preferencesServiceProvider),
  ),
);

final AsyncNotifierProvider<EventController, List<LincaEvent>>
    eventControllerProvider =
    AsyncNotifierProvider<EventController, List<LincaEvent>>(
        EventController.new);

final Provider<GroupRepository> groupRepositoryProvider =
    Provider<GroupRepository>(
  (Ref ref) => GroupRepository(
    uid: ref.watch(uidProvider),
    fireStore: ref.watch(fireStoreProvider),
    preferences: ref.watch(preferencesServiceProvider),
  ),
);

final AsyncNotifierProvider<GroupController, List<Group>>
    groupControllerProvider =
    AsyncNotifierProvider<GroupController, List<Group>>(GroupController.new);

final Provider<TagRepository> tagRepositoryProvider = Provider<TagRepository>(
  (Ref ref) => TagRepository(
    uid: ref.watch(uidProvider),
    fireStore: ref.watch(fireStoreProvider),
    preferences: ref.watch(preferencesServiceProvider),
  ),
);

final AsyncNotifierProvider<TagController, List<Tag>> tagControllerProvider =
    AsyncNotifierProvider<TagController, List<Tag>>(TagController.new);

final Provider<VenueRepository> venueRepositoryProvider =
    Provider<VenueRepository>(
  (Ref ref) => VenueRepository(
    uid: ref.watch(uidProvider),
    fireStore: ref.watch(fireStoreProvider),
    preferences: ref.watch(preferencesServiceProvider),
  ),
);

final AsyncNotifierProvider<VenueController, List<Venue>>
    venueControllerProvider =
    AsyncNotifierProvider<VenueController, List<Venue>>(VenueController.new);

final Provider<ParticipationRepository> participationRepositoryProvider =
    Provider<ParticipationRepository>(
  (Ref ref) => ParticipationRepository(
    uid: ref.watch(uidProvider),
    fireStore: ref.watch(fireStoreProvider),
    preferences: ref.watch(preferencesServiceProvider),
  ),
);

final AsyncNotifierProvider<ParticipationController, List<ParticipationInfo>>
    participationControllerProvider =
    AsyncNotifierProvider<ParticipationController, List<ParticipationInfo>>(
        ParticipationController.new);

final Provider<FriendRepository> friendRepositoryProvider =
    Provider<FriendRepository>(
  (Ref ref) => FriendRepository(
    uid: ref.watch(uidProvider),
    fireStore: ref.watch(fireStoreProvider),
    preferences: ref.watch(preferencesServiceProvider),
  ),
);

final Provider<FriendController> friendControllerProvider =
    Provider<FriendController>((Ref ref) {
  final FriendRepository friendRepository = ref.read(friendRepositoryProvider);
  return FriendController(
    friendRepository: friendRepository,
  );
});

final Provider<UserEventRepository> userEventRepositoryProvider =
    Provider<UserEventRepository>(
  (Ref ref) => UserEventRepository(
    uid: ref.watch(uidProvider),
    fireStore: ref.watch(fireStoreProvider),
    preferences: ref.watch(preferencesServiceProvider),
  ),
);

final AsyncNotifierProvider<UserEventController, List<LincaEvent>>
    userEventControllerProvider =
    AsyncNotifierProvider<UserEventController, List<LincaEvent>>(
        UserEventController.new);
