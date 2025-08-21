import 'package:auto_route/auto_route.dart';
import 'package:fefeyo_flutter_template/core/router/app_router.gr.dart';
import 'package:fefeyo_flutter_template/core/utils/context_extension.dart';
import 'package:flutter/material.dart';

import '../../../core/asset_gen/assets.gen.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

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
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(Assets.images.userIcon.path),
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(height: 10),
                Text(
                  'John Doe',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  'john.doe @example.com',
                  style: context.textTheme.bodyMedium?.copyWith(
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
              'LinCaカード',
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
            onTap: () => transitPage(const MyEventRoute()),
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
              'イベント',
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
              '設定',
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
          const SizedBox(height: 16,)
        ],
      ),
    );
  }
}
