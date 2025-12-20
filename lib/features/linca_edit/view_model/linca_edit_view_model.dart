import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/favorite_badges.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import 'package:linca_otaku_support/core/utils/favorite_badges_extension.dart';
import 'package:linca_otaku_support/features/linca_edit/data/sns_type.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/network/model/group.dart';
import '../../../core/network/model/linca_badge.dart';
import '../data/linca_edit_state.dart';

final AutoDisposeStateNotifierProvider<LincaEditViewModel, LincaEditState>
    lincaEditViewModelProvider =
    StateNotifierProvider.autoDispose<LincaEditViewModel, LincaEditState>(
        (Ref ref) {
  final List<LincaBadge> badges =
      ref.watch(badgeControllerProvider).value ?? <LincaBadge>[];
  return LincaEditViewModel(badges: badges);
});

class LincaEditViewModel extends StateNotifier<LincaEditState> {
  LincaEditViewModel({required this.badges}) : super(const LincaEditState());

  final List<LincaBadge> badges;

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

  void updateDisplayName(String name) {
    state = state.copyWith(
      userProfile: state.userProfile
          ?.copyWith(user: state.userProfile!.user.copyWith(displayName: name)),
    );
  }

  void updateBio(String bio) {
    state = state.copyWith(
      userProfile: state.userProfile
          ?.copyWith(user: state.userProfile!.user.copyWith(bio: bio)),
    );
  }

  void updateSnsLink(SnsType type, String value) {
    final UserProfile? userProfile = state.userProfile;
    if (userProfile == null) return;

    final Map<String, String> updatedLinks = Map<String, String>.from(
      userProfile.user.links,
    );

    final String key = switch (type) {
      SnsType.x => 'x',
      SnsType.instagram => 'instagram',
      SnsType.bluesky => 'bluesky',
    };
    updatedLinks[key] = value;

    state = state.copyWith(
      userProfile: userProfile.copyWith(
        user: userProfile.user.copyWith(links: updatedLinks),
      ),
    );
  }

  /// ユーザーの「お気に入りバッジ」リストを更新します。
  ///
  /// [changeBadge] は、既に選択されているバッジ（変更元）を指定します。
  /// - null の場合は、新規追加として扱われます。
  ///
  /// [selectedBadge] は、今回新たに選択されたバッジを指定します。
  /// - slug が空文字列（`''`）の場合は「未選択」として扱い、該当のバッジを削除します。
  ///
  /// 処理内容：
  /// - `changeBadge` が null で `selectedBadge.slug` が空でない → 追加
  /// - `changeBadge` が null で `selectedBadge.slug` が空 → 何もしない
  /// - `changeBadge` が存在し `selectedBadge.slug` が空でない → 置き換え
  /// - `changeBadge` が存在し `selectedBadge.slug` が空 → 削除
  ///
  void updateFavoriteBadges({
    required LincaBadge? changeBadge,
    required LincaBadge selectedBadge,
    required int index,
  }) {
    // 変更がない場合はスキップ
    if (changeBadge?.slug == selectedBadge.slug) return;

    FavoriteBadges favoriteBadges =
        state.userProfile?.favoriteBadges ?? const FavoriteBadges();

    if (selectedBadge.slug.isEmpty) {
      favoriteBadges = favoriteBadges.setBadge(index: index);
    } else {
      favoriteBadges =
          favoriteBadges.setBadge(index: index, badge: selectedBadge);
    }

    // Stateを更新
    state = state.copyWith(
      userProfile: state.userProfile?.copyWith(
        user: state.userProfile!.user.copyWith(
          favoriteBadges: favoriteBadges.toSlugList,
        ),
        favoriteBadges: favoriteBadges,
      ),
    );
  }
}
