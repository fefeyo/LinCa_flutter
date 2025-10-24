import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/network/model/group.dart';
import '../../../core/network/model/linca_badge.dart';
import '../data/linca_edit_state.dart';

final StateNotifierProvider<LincaEditViewModel, LincaEditState>
    lincaEditViewModelProvider =
    StateNotifierProvider<LincaEditViewModel, LincaEditState>((Ref ref) {
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
  }) {
    // 変更がない場合はスキップ
    if (changeBadge?.slug == selectedBadge.slug) return;

    final List<String> favoriteBadges =
        List<String>.from(state.userProfile?.user.favoriteBadges ?? <String>[]);

    if (selectedBadge.slug.isEmpty) {
      if (changeBadge != null) {
        // バッジの削除（選択を解除）
        favoriteBadges.remove(changeBadge.slug);
      }
    } else {
      // バッジの追加または差し替え
      if (changeBadge != null) {
        favoriteBadges.remove(changeBadge.slug);
      }
      if (!favoriteBadges.contains(selectedBadge.slug)) {
        favoriteBadges.add(selectedBadge.slug);
      }
    }

    state = state.copyWith(
      userProfile: state.userProfile?.copyWith(
        user: state.userProfile!.user.copyWith(favoriteBadges: favoriteBadges),
        favoriteBadges: badges
            .where((LincaBadge badge) => favoriteBadges.contains(badge.slug))
            .toList(),
      ),
    );
  }
}
