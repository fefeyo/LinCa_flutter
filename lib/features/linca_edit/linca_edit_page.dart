import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/auth/providers.dart';
import 'package:linca_otaku_support/core/models/favorite_badges.dart';
import 'package:linca_otaku_support/core/models/user_profile.dart';
import 'package:linca_otaku_support/core/network/controller/user_controller.dart';
import 'package:linca_otaku_support/core/network/model/group.dart';
import 'package:linca_otaku_support/core/network/model/linca_badge.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/favorite_badges_extension.dart';
import 'package:linca_otaku_support/core/utils/image_uploader.dart';

import '../../core/asset_gen/assets.gen.dart';
import '../../core/network/model/user.dart';
import '../../core/router/app_router.gr.dart';
import 'data/linca_edit_state.dart';
import 'view_model/linca_edit_view_model.dart';

@RoutePage()
class LincaEditPage extends HookConsumerWidget {
  const LincaEditPage({
    super.key,
    required this.userProfile,
  });

  final UserProfile userProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LincaEditState state = ref.watch(lincaEditViewModelProvider);
    final LincaEditViewModel viewModel =
        ref.read(lincaEditViewModelProvider.notifier);
    final TextEditingController displayNameController =
        TextEditingController(text: userProfile.user.displayName);
    final TextEditingController bioController =
        TextEditingController(text: userProfile.user.bio);
    final TextEditingController xController =
        TextEditingController(text: userProfile.user.links['x']);
    final TextEditingController instagramController =
        TextEditingController(text: userProfile.user.links['instagram']);
    final TextEditingController blueskyController =
        TextEditingController(text: userProfile.user.links['bluesky']);
    final List<Group> groups =
        ref.watch(groupControllerProvider).value ?? <Group>[];
    final UserController userController =
        ref.read(userControllerProvider.notifier);
    final String? uid = ref.watch(uidProvider);

    useEffect(() {
      Future<void>.microtask(() => viewModel.initialize(userProfile));
      return null;
    }, const <Object?>[]);

    void updateUserData() async {
      final User user = state.userProfile?.user.copyWith(
            displayName: displayNameController.text,
            bio: bioController.text,
            links: <String, String>{
              'x': xController.text,
              'instagram': instagramController.text,
              'bluesky': blueskyController.text,
            },
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.linca_edit_success_save),
          ),
        );
        context.router.pop();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.edit_my_linca_title),
        actions: <Widget>[
          IconButton(onPressed: updateUserData, icon: const Icon(Icons.save))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      if (uid == null) return;
                      // ローディング表示
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                      final String? photoUrl =
                          await pickCompressAndUploadImage(uid);
                      if (context.mounted) context.router.pop();
                      if (photoUrl == null) return;
                      userController.updateUserPhoto(photoUrl);
                      viewModel.updateUserPhoto(photoUrl);
                    },
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colorScheme.surfaceContainer,
                          width: 3,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundImage:
                            state.userProfile?.user.photoUrl.isNotEmpty == true
                                ? CachedNetworkImageProvider(
                                    state.userProfile!.user.photoUrl)
                                : AssetImage(Assets.images.userIcon.path),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: displayNameController,
                      style: context.textTheme.titleMedium,
                      decoration: InputDecoration(
                        labelText: context.l10n.linca_edit_label_nickname,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'お気に入りバッジ',
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildSelectFavoriteBadgeWidget(
                  context: context,
                  favoriteBadges: state.userProfile?.favoriteBadges ??
                      const FavoriteBadges(),
                  onTap: (
                    LincaBadge? changeBadge,
                    LincaBadge selectedBadge,
                    int index,
                  ) {
                    viewModel.updateFavoriteBadges(
                      changeBadge: changeBadge,
                      selectedBadge: selectedBadge,
                      index: index,
                    );
                  }),
              const SizedBox(height: 16),
              Text(
                context.l10n.linca_edit_label_favorite_group,
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 8,
                children: groups
                    .where((Group group) => group.active)
                    .map(
                      (Group group) => ChoiceChip(
                        showCheckmark: false,
                        label: Text(
                          group.name,
                          style: context.textTheme.bodyMedium,
                        ),
                        selected:
                            state.userProfile?.favoriteGroups.contains(group) ==
                                true,
                        onSelected: (bool selected) {
                          final List<Group> current = List<Group>.of(
                              state.userProfile?.favoriteGroups ?? <Group>[]);
                          if (selected) {
                            current.add(group);
                          } else {
                            current.remove(group);
                          }
                          viewModel.updateFavoriteGroups(current);
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                style: context.textTheme.bodyMedium,
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: context.l10n.linca_edit_label_bio,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: xController,
                style: context.textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: context.l10n.linca_edit_label_user_id_x,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: instagramController,
                style: context.textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: context.l10n.linca_edit_label_user_id_instagram,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: blueskyController,
                style: context.textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: context.l10n.linca_edit_label_user_id_bluesky,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
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
              color: Colors.grey,
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
                  lincaBadge?.name ?? 'バッジ未選択',
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
