import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/auth/providers.dart';
import 'package:linca_otaku_support/core/models/user_profile.dart';
import 'package:linca_otaku_support/core/network/controller/user_controller.dart';
import 'package:linca_otaku_support/core/network/model/group.dart';
import 'package:linca_otaku_support/core/network/model/linca_badge.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/image_uploader.dart';

import '../../core/asset_gen/assets.gen.dart';
import '../../core/network/model/user.dart';
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
            favoriteBadges: state.userProfile?.favoriteBadges
                    .map((LincaBadge badge) => badge.slug)
                    .toList() ??
                <String>[],
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
                          color: context.colorScheme.surface,
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
                  const SizedBox(
                    width: 16,
                  ),
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
              const SizedBox(
                height: 32,
              ),
              Text(
                context.l10n.linca_edit_label_favorite_group,
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(
                height: 4,
              ),
              Wrap(
                spacing: 4,
                runSpacing: 8,
                children: groups
                    .map(
                      (Group group) => ChoiceChip(
                        label: Text(
                          group.name,
                          style: context.textTheme.titleMedium,
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
              const SizedBox(
                height: 16,
              ),
              TextField(
                controller: bioController,
                style: context.textTheme.titleMedium,
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: context.l10n.linca_edit_label_bio,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextField(
                controller: xController,
                style: context.textTheme.titleMedium,
                decoration: InputDecoration(
                  labelText: context.l10n.linca_edit_label_user_id_x,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextField(
                controller: instagramController,
                style: context.textTheme.titleMedium,
                decoration: InputDecoration(
                  labelText: context.l10n.linca_edit_label_user_id_instagram,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextField(
                controller: blueskyController,
                style: context.textTheme.titleMedium,
                decoration: InputDecoration(
                  labelText: context.l10n.linca_edit_label_user_id_bluesky,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
