import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/models/user_profile.dart';
import 'package:linca_otaku_support/core/network/model/group.dart';
import 'package:linca_otaku_support/core/network/model/linca_badge.dart';
import 'package:linca_otaku_support/core/utils/color_extension.dart';
import 'package:linca_otaku_support/core/widgets/event/event_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/utils/context_extension.dart';
import '../../../core/asset_gen/assets.gen.dart';

class LincaVertical extends HookConsumerWidget {
  const LincaVertical({
    super.key,
    required this.userProfile,
    this.upcomingEvent,
    this.tintColor,
    this.isFullScreen = false,
    this.animationTag = '',
    this.onTap,
  });

  final UserProfile userProfile;
  final LincaEvent? upcomingEvent;
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
      const double badgeSize = 50;

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
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // 推しグループ
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
                      // 自己紹介
                      if (userProfile.user.bio.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                            userProfile.user.bio,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: isFullScreen ? null : 2,
                            overflow:
                            isFullScreen ? null : TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),),
                        ),
                      ],
                      const SizedBox(height: 16),

                      ..._buildUpcomingEvent(
                        context: context,
                        upcomingEvent: upcomingEvent,
                      ),

                      // Xアカウント、Instagramアカウント、Blueskyアカウント
                      _buildSnsAccounts(context),
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
                  child: CircleAvatar(
                    backgroundImage: userProfile.user.photoUrl.isNotEmpty ==
                            true
                        ? CachedNetworkImageProvider(userProfile.user.photoUrl)
                        : AssetImage(Assets.images.userIcon.path),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: userProfile.favoriteBadges
                    .map(
                      (LincaBadge badge) => SizedBox(
                        width: badgeSize,
                        height: badgeSize,
                        child: CachedNetworkImage(imageUrl: badge.iconUrl),
                      ),
                    )
                    .toList(),
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

  List<Widget> _buildUpcomingEvent({
    required BuildContext context,
    required LincaEvent? upcomingEvent,
  }) {
    if (!isFullScreen) return <Widget>[];

    if (upcomingEvent != null) {
      return <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              context.l10n.latest_participate_upcoming_event,
              style: context.textTheme.titleMedium,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: EventCard(
            lincaEvent: upcomingEvent,
          ),
        ),
        const SizedBox(height: 16),
      ];
    } else {
      return <Widget>[];
    }
  }

  Widget _buildSnsAccounts(BuildContext context) {
    if (!isFullScreen) return const SizedBox.shrink();
    const double iconSize = 32;
    return Row(
      children: <Widget>[
        userProfile.user.links['x']?.isNotEmpty == true
            ? Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => launchUrl(
                    Uri.parse(
                      context.l10n.sns_scheme_x(userProfile.user.links['x']!),
                    ),
                  ),
                  child: Assets.icons.x.svg(
                    width: iconSize,
                    height: iconSize,
                    colorFilter:
                        const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                  ),
                ),
              )
            : const SizedBox.shrink(),
        userProfile.user.links['instagram']?.isNotEmpty == true
            ? Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => launchUrl(
                    Uri.parse(
                      context.l10n.sns_scheme_instagram(
                          userProfile.user.links['instagram']!),
                    ),
                  ),
                  child: Assets.icons.instagram.svg(
                    width: iconSize,
                    height: iconSize,
                    colorFilter: const ColorFilter.mode(
                        Color(0xFFFF0069), BlendMode.srcIn),
                  ),
                ),
              )
            : const SizedBox.shrink(),
        userProfile.user.links['bluesky']?.isNotEmpty == true
            ? Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => launchUrl(
                      Uri.parse(
                        context.l10n.sns_scheme_bluesky(
                            userProfile.user.links['bluesky']!),
                      ),
                      mode: LaunchMode.externalApplication),
                  child: Assets.icons.bluesky.svg(
                    width: iconSize,
                    height: iconSize,
                    colorFilter: const ColorFilter.mode(
                        Color(0xFF0285FF), BlendMode.srcIn),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
