import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/user_profile.dart';
import 'package:linca_otaku_support/core/network/model/group.dart';
import 'package:linca_otaku_support/core/utils/color_extension.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/context_extension.dart';
import '../../../core/asset_gen/assets.gen.dart';

class LincaVertical extends HookConsumerWidget {
  const LincaVertical({
    super.key,
    required this.userProfile,
    this.tintColor,
    this.isFullScreen = false,
    this.animationTag = '',
    this.onTap,
  });

  final UserProfile userProfile;
  final Color? tintColor;
  final bool isFullScreen;
  final String animationTag;
  final Function(UserProfile userProfile, String animationTag)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color backgroundColor = context.theme.brightness == Brightness.light
        ? context.colorScheme.surface
        : context.colorScheme.surfaceContainer;

    Widget buildCard() {
      const double iconSize = 32;
      const double badgeSize = 30;

      return Card(
        color: backgroundColor,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // 上帯
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          (tintColor ?? context.colorScheme.primary)
                              .withValues(alpha: .95),
                          (tintColor ?? context.colorScheme.primary)
                              .withValues(alpha: .70),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 45),

                  // テキスト群
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 8),
                      Text(
                        userProfile.user.displayName,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 16),
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 6,
                          runSpacing: 4,
                          children: userProfile.favoriteGroups
                              .map((Group group) => Chip(
                                    label: Text(
                                      group.name,
                                      style: context.textTheme.labelMedium
                                          ?.copyWith(
                                        color: context.colorScheme.surface,
                                      ),
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    side: BorderSide.none,
                                    backgroundColor: colorFromHex(group.color),
                                  ))
                              .toList(),
                        ),
                      ),
                      if (userProfile.user.bio.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 16),
                          child: Text(
                            userProfile.user.bio,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: isFullScreen ? null : 2,
                            overflow:
                                isFullScreen ? null : TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                      if (!isFullScreen) const SizedBox(height: 16),
                      if (isFullScreen)
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => launchUrl(
                                    Uri.parse('https://x.com/nigafefe')),
                                child: Assets.icons.x.svg(
                                  width: iconSize,
                                  height: iconSize,
                                  colorFilter: const ColorFilter.mode(
                                      Colors.black, BlendMode.srcIn),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => launchUrl(Uri.parse(
                                    'https://instagram.com/your_handle')),
                                child: Assets.icons.instagram.svg(
                                  width: iconSize,
                                  height: iconSize,
                                  colorFilter: const ColorFilter.mode(
                                      Color(0xFFFF0069), BlendMode.srcIn),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => launchUrl(
                                    Uri.parse(
                                        'https://bsky.app/profile/your_handle'),
                                    mode: LaunchMode.externalApplication),
                                child: Assets.icons.bluesky.svg(
                                  width: iconSize,
                                  height: iconSize,
                                  colorFilter: const ColorFilter.mode(
                                      Color(0xFF0285FF), BlendMode.srcIn),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // アバター（帯と本文の境目に重ねる）
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: backgroundColor, width: 3),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Image(
                    image: AssetImage(Assets.images.userIcon.path),
                  ),
                ),
              ),
            ),

            /// TODO: バッジ機能の実装
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: badgeSize,
                    height: badgeSize,
                    child: Image(
                      image: AssetImage(Assets.images.userIcon.path),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: badgeSize,
                    height: badgeSize,
                    child: Image(
                      image: AssetImage(Assets.images.userIcon.path),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: badgeSize,
                    height: badgeSize,
                    child: Image(
                      image: AssetImage(Assets.images.userIcon.path),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget buildBody() {
      if (onTap != null) {
        return InkWell(
          onTap: () => onTap?.call(userProfile, animationTag),
          borderRadius: BorderRadius.circular(20),
          child: isFullScreen
              ? SizedBox.expand(
                  child: buildCard(),
                )
              : buildCard(),
        );
      } else {
        return isFullScreen
            ? SizedBox.expand(
                child: buildCard(),
              )
            : buildCard();
      }
    }

    return Hero(
      tag: animationTag,
      child: Material(
        color: Colors.transparent,
        child: buildBody(),
      ),
    );
  }
}
