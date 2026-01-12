import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/auth/providers.dart';
import 'package:linca_otaku_support/core/constants/analytics_event.dart';
import 'package:linca_otaku_support/core/constants/analytics_screen.dart';
import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:linca_otaku_support/core/models/favorite_badges.dart';
import 'package:linca_otaku_support/core/models/user_profile.dart';
import 'package:linca_otaku_support/core/network/controller/user_controller.dart';
import 'package:linca_otaku_support/core/network/model/group.dart';
import 'package:linca_otaku_support/core/network/model/linca_badge.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/event_analytics_manager.dart';
import 'package:linca_otaku_support/core/utils/favorite_badges_extension.dart';
import 'package:linca_otaku_support/core/utils/image_uploader.dart';
import 'package:linca_otaku_support/core/utils/map_value_extension.dart';
import 'package:linca_otaku_support/core/utils/screen_analytics_manager.dart';
import 'package:linca_otaku_support/core/widgets/common/common_simple_dialog.dart';
import 'package:linca_otaku_support/features/linca_edit/data/sns_type.dart';
import 'package:reorderables/reorderables.dart';

import '../../core/asset_gen/assets.gen.dart';
import '../../core/network/model/user.dart';
import '../../core/router/app_router.gr.dart';
import 'data/linca_edit_state.dart';
import 'view_model/linca_edit_view_model.dart';

@RoutePage()
class LincaEditPage extends HookConsumerWidget
    with ScreenAnalyticsManager, EventAnalyticsManager {
  const LincaEditPage({
    super.key,
    required this.userProfile,
  });

  final UserProfile userProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logScreen(AnalyticsScreen.editMyLincaCard);

    final LincaEditState state = ref.watch(lincaEditViewModelProvider);
    final LincaEditViewModel viewModel =
        ref.read(lincaEditViewModelProvider.notifier);
    final List<Group> groups =
        ref.watch(groupControllerProvider).value ?? <Group>[];
    final UserController userController =
        ref.read(userControllerProvider.notifier);
    final String? uid = ref.watch(uidProvider);
    final TextEditingController nickNameTextControlelr =
        useTextEditingController(text: userProfile.user.displayName);
    final TextEditingController bioTextController =
        useTextEditingController(text: userProfile.user.bio);
    final TextEditingController twitterTextController =
        useTextEditingController(text: userProfile.user.links.x);
    final TextEditingController instagramTextController =
        useTextEditingController(text: userProfile.user.links.instagram);
    final TextEditingController blueskyTextController =
        useTextEditingController(text: userProfile.user.links.bluesky);

    useEffect(() {
      Future<void>.microtask(() => viewModel.initialize(userProfile));
      return null;
    }, const <Object?>[]);

    void updateUserData() async {
      logEvent(event: AnalyticsEvent.editMyLincaSaveClick);

      final User user = state.userProfile?.user.copyWith(
            photoUrl: state.userProfile?.user.photoUrl ?? '',
            favoriteGroups: state.userProfile?.favoriteGroups
                    .map((Group group) => group.slug)
                    .toList() ??
                <String>[],
            favoriteBadges: <String>[
              state.userProfile?.favoriteBadges.badge01?.slug ?? '',
              state.userProfile?.favoriteBadges.badge02?.slug ?? '',
              state.userProfile?.favoriteBadges.badge03?.slug ?? '',
            ],
          ) ??
          const User();
      await userController.updateUserData(user);
      if (!context.mounted) return;
      context.showSuccessSnackBar(
        message: context.l10n.common_save_suceeded,
        effect: () => context.router.pop(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.edit_my_linca_title,
          style: context.textTheme.titleMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: updateUserData,
        icon: const Icon(Icons.save),
        label: Text(
          context.l10n.common_save,
          style: context.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, _) {
          if (didPop) return;
          if (userProfile != state.userProfile) {
            CommonSimpleDialog.show(
              context: context,
              title: context.l10n.linca_edit_destruction_message,
              onClickOk: () => context.router.pop(),
              onClickCancel: () {},
            );
            return;
          }
          context.router.pop();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // プロフィール画像と名前
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: <Widget>[
                            CircleAvatar(
                              radius: 46,
                              backgroundImage:
                                  state.userProfile?.user.photoUrl.isNotEmpty ==
                                          true
                                      ? CachedNetworkImageProvider(
                                          state.userProfile!.user.photoUrl)
                                      : AssetImage(Assets.images.userIcon.path)
                                          as ImageProvider,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () async {
                                  if (uid == null) return;
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                  final String? photoUrl =
                                      await pickCompressAndUploadImage(
                                    uid: uid,
                                    uploadPath: 'users/$uid/profile.jpg',
                                    imageQuality: ImageQuality.icon,
                                  );
                                  if (context.mounted) context.router.pop();
                                  if (photoUrl == null) return;
                                  userController.updateUserPhoto(photoUrl);
                                  viewModel.updateUserPhoto(photoUrl);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: context.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: nickNameTextControlelr,
                            maxLength: AppConstants.userNameMaxLength,
                            onChanged: viewModel.updateDisplayName,
                            style: context.textTheme.titleMedium,
                            decoration: InputDecoration(
                              labelText: context.l10n.linca_edit_label_nickname,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // お気に入りバッジ
                _sectionTitle(
                    context, context.l10n.linca_edit_favorite_badge_title),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _buildSelectFavoriteBadgeWidget(
                      context: context,
                      favoriteBadges: state.userProfile?.favoriteBadges ??
                          const FavoriteBadges(),
                      onTap: (LincaBadge? changeBadge, LincaBadge selectedBadge,
                          int index) {
                        viewModel.updateFavoriteBadges(
                          changeBadge: changeBadge,
                          selectedBadge: selectedBadge,
                          index: index,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 自己紹介
                _sectionTitle(context, context.l10n.linca_edit_label_bio),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: bioTextController,
                      onChanged: viewModel.updateBio,
                      style: context.textTheme.bodyMedium,
                      maxLines: 10,
                      maxLength: AppConstants.bioMaxLength,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: context.l10n.linca_edit_bio_label_hint,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // SNSリンク
                _sectionTitle(context, context.l10n.sns_link_section_title),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: <Widget>[
                        _snsField(
                          context,
                          icon: Icons.alternate_email,
                          label: context.l10n.sns_title_x,
                          textController: twitterTextController,
                          onChanged: (String value) =>
                              viewModel.updateSnsLink(SnsType.x, value),
                        ),
                        const SizedBox(height: 12),
                        _snsField(
                          context,
                          icon: Icons.camera_alt_outlined,
                          label: context.l10n.sns_title_instagram,
                          textController: instagramTextController,
                          onChanged: (String value) =>
                              viewModel.updateSnsLink(SnsType.instagram, value),
                        ),
                        const SizedBox(height: 12),
                        _snsField(
                          context,
                          icon: Icons.cloud_outlined,
                          label: context.l10n.sns_title_bluesky,
                          textController: blueskyTextController,
                          onChanged: (String value) =>
                              viewModel.updateSnsLink(SnsType.bluesky, value),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                _sectionTitle(
                    context, context.l10n.linca_edit_label_favorite_tag),
                const SizedBox(height: 4),
                Text(
                  context.l10n.linca_edit_label_favorite_tag_description(
                    AppConstants.maxProfileTagCount,
                    AppConstants.maxSimpleProfileTagCount,
                  ),
                  style: context.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: Text(
                    context.l10n.linca_edit_label_edit_tag,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(double.infinity, 36),
                  ),
                  onPressed: () async {
                    final List<Group>? result =
                        await context.router.push<List<Group>>(
                      SelectFavoriteTagRoute(
                        groups: groups,
                        favoriteTags:
                            state.userProfile?.favoriteGroups ?? <Group>[],
                        maxTagCount: AppConstants.maxProfileTagCount,
                      ),
                    );
                    if (result != null) {
                      viewModel.updateFavoriteGroups(result);
                    }
                  },
                ),
                const SizedBox(height: 8),
                if (state.userProfile?.favoriteGroups.isNotEmpty == true)
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: ReorderableWrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          needsLongPressDraggable: true,
                          onReorder: (int oldIndex, int newIndex) {
                            final List<Group> current = List<Group>.of(
                                state.userProfile?.favoriteGroups ?? <Group>[]);
                            final Group group = current.removeAt(oldIndex);
                            current.insert(newIndex, group);
                            viewModel.updateFavoriteGroups(current);
                          },
                          children: state.userProfile!.favoriteGroups
                              .asMap()
                              .entries
                              .map((MapEntry<int, Group> entry) {
                            final Group group = entry.value;
                            return Chip(
                              key: ValueKey<String>(group.id),
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(group.name),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.drag_indicator,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                              backgroundColor:
                                  context.colorScheme.primaryContainer,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _snsField(
    BuildContext context, {
    required IconData icon,
    required String label,
    required TextEditingController textController,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: textController,
      onChanged: onChanged,
      style: context.textTheme.bodyMedium,
      maxLength: AppConstants.snsMaxLength,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: context.colorScheme.primary),
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSelectFavoriteBadgeWidget({
    required BuildContext context,
    required FavoriteBadges favoriteBadges,
    required Function(
      LincaBadge? changeBadge,
      LincaBadge selectedBadge,
      int index,
    ) onTap,
  }) {
    Widget buildBadgeWidget({
      required LincaBadge? lincaBadge,
      required int index,
    }) {
      final CachedNetworkImageProvider? imageProvider = lincaBadge != null
          ? CachedNetworkImageProvider(lincaBadge.iconUrl)
          : null;
      return InkWell(
        onTap: () async {
          final LincaBadge? result = await context.router
              .push<LincaBadge>(AcquiredBadgeRoute(selectable: true));
          if (result != null) {
            onTap(lincaBadge, result, index);
          }
        },
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 100,
                height: 100,
                child: imageProvider != null
                    ? Image(image: imageProvider)
                    : const Icon(
                        Icons.add_circle_outline,
                        size: 40,
                        color: Colors.grey,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  lincaBadge?.name ??
                      context.l10n.acquired_badges_list_unselect,
                  style: context.textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List<Widget>.generate(3, (int index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: index > 0 ? 8 : 0),
            child: buildBadgeWidget(
              lincaBadge: favoriteBadges.toList[index],
              index: index,
            ),
          ),
        );
      }),
    );
  }
}
