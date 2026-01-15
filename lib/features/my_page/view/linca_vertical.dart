import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/models/linca_user.dart';
import 'package:linca_otaku_support/core/network/model/group.dart';
import 'package:linca_otaku_support/core/network/model/linca_badge.dart';
import 'package:linca_otaku_support/core/utils/color_extension.dart';
import 'package:linca_otaku_support/core/utils/favorite_badges_extension.dart';
import 'package:linca_otaku_support/core/utils/group_extension.dart';
import 'package:linca_otaku_support/core/widgets/common/common_close_button.dart';
import 'package:linca_otaku_support/core/widgets/dialog/image_preview_dialog.dart';
import 'package:linca_otaku_support/core/widgets/event/event_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/router/app_router.gr.dart';
import '../../../core/utils/context_extension.dart';
import '../../../core/asset_gen/assets.gen.dart';

class LincaVertical extends HookConsumerWidget {
  const LincaVertical({
    super.key,
    required this.lincaUser,
    this.upcomingEvents = const <LincaEvent>[],
    this.isFullScreen = false,
    this.animationTag = '',
    this.onTap,
    this.onClickFlip,
    this.onClickClose,
  });

  final LincaUser lincaUser;
  final List<LincaEvent> upcomingEvents;
  final bool isFullScreen;
  final String animationTag;
  final Function(LincaUser lincaUser, String animationTag)? onTap;
  final Function()? onClickFlip;
  final Function()? onClickClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color backgroundColor = context.theme.brightness == Brightness.light
        ? context.colorScheme.surface
        : context.colorScheme.surfaceContainer;
    final Color favoriteColor =
        lincaUser.favoriteGroups.getFavoriteColor(context);

    Widget buildCard() {
      return Card(
        color: backgroundColor,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 190),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // 推しタグ
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 6,
                        runSpacing: 4,
                        children: lincaUser.favoriteGroups
                            .take(isFullScreen
                                ? lincaUser.favoriteGroups.length
                                : AppConstants.maxSimpleProfileTagCount)
                            .map((Group group) => Chip(
                                  label: Text(
                                    group.name,
                                    style:
                                        context.textTheme.labelMedium?.copyWith(
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
                    if (lincaUser.user.bio.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            lincaUser.user.bio,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: isFullScreen ? null : 2,
                            overflow:
                                isFullScreen ? null : TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    ..._buildUpcomingEvent(
                      context: context,
                      upcomingEvents: upcomingEvents,
                    ),

                    // Xアカウント、Instagramアカウント、Blueskyアカウント
                    _buildSnsAccounts(context),

                    if (isFullScreen) const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      favoriteColor,
                      favoriteColor.withValues(alpha: .70),
                    ],
                  ),
                ),
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
                  child: GestureDetector(
                    onTap: () {
                      if (lincaUser.user.photoUrl.isNotEmpty == true &&
                          isFullScreen) {
                        ImagePreviewDialog.show(
                            context: context,
                            imageUrl: lincaUser.user.photoUrl);
                      }
                    },
                    child: CircleAvatar(
                      backgroundImage: lincaUser.user.photoUrl.isNotEmpty ==
                              true
                          ? CachedNetworkImageProvider(lincaUser.user.photoUrl)
                          : AssetImage(Assets.images.userIcon.path),
                    ),
                  ),
                ),
              ),
            ),

            // お気に入りバッジ一覧
            Positioned(
              top: 8,
              right: 8,
              child: SizedBox(
                width: 140,
                height: 50,
                child: Row(
                  children: lincaUser.favoriteBadges.toList
                      .map(
                        (LincaBadge? badge) => badge != null
                            ? Expanded(
                                child:
                                    CachedNetworkImage(imageUrl: badge.iconUrl))
                            : const Expanded(child: SizedBox.shrink()),
                      )
                      .toList(),
                ),
              ),
            ),
            if (isFullScreen)
              Positioned(
                top: 16,
                left: 16,
                child: CommonCloseButton(
                  onClose: () => onClickClose?.call(),
                ),
              ),
            if (isFullScreen)
              Positioned(
                bottom: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.sync, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black26,
                    shape: const CircleBorder(),
                    fixedSize: const Size(48, 48),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: onClickFlip,
                ),
              ),
            Positioned(
              top: 150,
              left: 0,
              right: 0,
              child: Text(
                lincaUser.user.displayName,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    Widget buildBody() {
      if (onTap != null) {
        return InkWell(
          onTap: () => onTap?.call(lincaUser, animationTag),
          borderRadius: BorderRadius.circular(20),
          child: isFullScreen
              ? SizedBox.expand(
                  child: buildCard(),
                )
              : SizedBox(
                  width: double.infinity,
                  child: buildCard(),
                ),
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
    required List<LincaEvent> upcomingEvents,
  }) {
    if (!isFullScreen) return <Widget>[];

    if (upcomingEvents.isNotEmpty) {
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
        for (final LincaEvent event in upcomingEvents)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: EventCard(
              lincaEvent: event,
              onClick: () => context.router.push(
                EventDetailRoute(
                  lincaEvent: event,
                ),
              ),
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
        lincaUser.user.links['x']?.isNotEmpty == true
            ? Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => launchUrl(
                    Uri.parse(
                      context.l10n.sns_scheme_x(lincaUser.user.links['x']!),
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
        lincaUser.user.links['instagram']?.isNotEmpty == true
            ? Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => launchUrl(
                    Uri.parse(
                      context.l10n.sns_scheme_instagram(
                          lincaUser.user.links['instagram']!),
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
        lincaUser.user.links['bluesky']?.isNotEmpty == true
            ? Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => launchUrl(
                      Uri.parse(
                        context.l10n.sns_scheme_bluesky(
                            lincaUser.user.links['bluesky']!),
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
