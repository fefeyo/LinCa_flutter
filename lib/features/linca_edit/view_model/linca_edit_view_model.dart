import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/network/model/group.dart';
import '../data/linca_edit_state.dart';

final StateNotifierProvider<LincaEditViewModel, LincaEditState>
    lincaEditViewModelProvider =
    StateNotifierProvider<LincaEditViewModel, LincaEditState>(
        (Ref ref) => LincaEditViewModel());

class LincaEditViewModel extends StateNotifier<LincaEditState> {
  LincaEditViewModel() : super(const LincaEditState());

  void initialize(UserProfile userProfile) {
    state = state.copyWith(userProfile: userProfile);
  }

  void updateFavoriteGroups(List<Group> groups) {
    state = state.copyWith(
      userProfile: state.userProfile?.copyWith(favoriteGroups: groups),
    );
  }

  void updateUserPhoto(String photoUrl) {
    state = state.copyWith(
      userProfile: state.userProfile?.copyWith(
          user: state.userProfile!.user.copyWith(photoUrl: photoUrl)),
    );
  }
}
