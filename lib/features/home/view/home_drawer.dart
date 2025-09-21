import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/network/model/user.dart';
import '../../../core/utils/context_extension.dart';
import '../../../core/asset_gen/assets.gen.dart';
import '../../../core/router/app_router.gr.dart';
import '../../../core/widgets/bottom_sheet/my_qr_bottom_sheet.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    super.key,
    required this.user,
  });

  final User user;

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
              color: context.colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(Assets.images.userIcon.path),
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(height: 10),
                Text(
                  user.displayName,
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
              style: context.textTheme.bodyLarge,
            ),
            onTap: () => changeTab(0),
          ),
          ListTile(
            leading: const Icon(Icons.event_note),
            title: Text(
              context.l10n.recent_event_title,
              style: context.textTheme.bodyLarge,
            ),
            onTap: () => changeTab(1),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              context.l10n.my_page_title,
              style: context.textTheme.bodyLarge,
            ),
            onTap: () => changeTab(2),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              context.l10n.common_linca_card,
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              context.l10n.traded_linca_list_title,
              style: context.textTheme.bodyLarge,
            ),
            onTap: () => transitPage(const MyEventRoute()),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              context.l10n.my_qr_code_title,
              style: context.textTheme.bodyLarge,
            ),
            onTap: () => MyQRBottomSheet.show(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              context.l10n.edit_my_linca_title,
              style: context.textTheme.bodyLarge,
            ),
            onTap: () => transitPage(const MyEventRoute()),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              context.l10n.obtained_badges_title,
              style: context.textTheme.bodyLarge,
            ),
            onTap: () => transitPage(const MyEventRoute()),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              context.l10n.common_event,
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              context.l10n.created_events_title,
              style: context.textTheme.bodyLarge,
            ),
            onTap: () => transitPage(const MyEventRoute()),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              context.l10n.common_setting,
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              context.l10n.app_settings_title,
              style: context.textTheme.bodyLarge,
            ),
            onTap: () => transitPage(const MyEventRoute()),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              context.l10n.delete_account_title,
              style: context.textTheme.bodyLarge,
            ),
            onTap: () => transitPage(const MyEventRoute()),
          ),
          const SizedBox(
            height: 16,
          )
        ],
      ),
    );
  }
}
