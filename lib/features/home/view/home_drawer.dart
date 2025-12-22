import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/models/linca_user.dart';
import 'package:linca_otaku_support/core/utils/group_extension.dart';
import 'package:linca_otaku_support/core/utils/linca_user_extension.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/utils/context_extension.dart';
import '../../../core/asset_gen/assets.gen.dart';
import '../../../core/router/app_router.gr.dart';
import '../../../core/widgets/bottom_sheet/my_qr_bottom_sheet.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    super.key,
    required this.lincaUser,
  });

  final LincaUser lincaUser;

  @override
  Widget build(BuildContext context) {
    void transitPage(PageRouteInfo routeInfo) {
      context.router.pop();
      context.router.push(routeInfo);
    }

    void changeTab(int index) {
      context.router.pop();
      context.tabsRouter.setActiveIndex(index);
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  lincaUser.favoriteGroups.getFavoriteColor(context),
                  lincaUser.favoriteGroups
                      .getFavoriteColor(context)
                      .withValues(alpha: .70),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 75,
                  height: 75,
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
                    backgroundImage: lincaUser.user.photoUrl.isNotEmpty == true
                        ? CachedNetworkImageProvider(lincaUser.user.photoUrl)
                        : AssetImage(Assets.images.userIcon.path),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  lincaUser.user.displayName,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: Text(
              context.l10n.my_event_title,
              style: context.textTheme.bodyMedium,
            ),
            onTap: () => changeTab(0),
          ),
          ListTile(
            leading: const Icon(Icons.event_note),
            title: Text(
              context.l10n.recent_event_title,
              style: context.textTheme.bodyMedium,
            ),
            onTap: () => changeTab(1),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              context.l10n.my_page_title,
              style: context.textTheme.bodyMedium,
            ),
            onTap: () => changeTab(2),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              context.l10n.common_linca_card,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: Text(
              context.l10n.edit_my_linca_title,
              style: context.textTheme.bodyMedium,
            ),
            onTap: () => transitPage(
              LincaEditRoute(userProfile: lincaUser.userProfile),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.recent_actors),
            title: Text(
              context.l10n.traded_linca_list_title,
              style: context.textTheme.bodyMedium,
            ),
            onTap: () => transitPage(const TradedLincaListRoute()),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: Text(
              context.l10n.my_qr_code_title,
              style: context.textTheme.bodyMedium,
            ),
            onTap: () => MyQRBottomSheet.show(context),
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: Text(
              context.l10n.acquired_badges_title,
              style: context.textTheme.bodyMedium,
            ),
            onTap: () => transitPage(AcquiredBadgeRoute()),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              context.l10n.common_event,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit_calendar),
            title: Text(
              context.l10n.created_events_title,
              style: context.textTheme.bodyMedium,
            ),
            onTap: () => transitPage(const CreatedEventListRoute()),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              context.l10n.common_setting,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(
              context.l10n.app_settings_title,
              style: context.textTheme.bodyMedium,
            ),
            onTap: () => openAppSettings(),
          ),
          const SizedBox(
            height: 16,
          )
        ],
      ),
    );
  }
}
