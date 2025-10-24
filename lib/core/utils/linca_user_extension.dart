import '../models/linca_user.dart';
import '../models/user_profile.dart';

extension LincaUserExtension on LincaUser {
  UserProfile get userProfile => UserProfile(
        user: user,
        favoriteGroups: favoriteGroups,
        favoriteBadges: favoriteBadges,
      );
}
