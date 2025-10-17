import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/constants/event_type.dart';

import '../../../core/router/app_router.gr.dart';
import '../../../core/utils/context_extension.dart';
import '../../../features/create_event/data/create_event_type.dart';

class AddEventBottomSheet extends StatelessWidget {
  const AddEventBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    void transitPage(PageRouteInfo routeInfo) {
      context.router.pop();
      context.router.push(routeInfo);
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // ← キーボード重なり対策
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: double.infinity,
          maxHeight: 400,
        ),
        child: Column(
          children: <Widget>[
            Text(
              context.l10n.add_event_title,
              style: context.textTheme.headlineMedium,
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: <Widget>[
                  ListTile(
                    tileColor: context.colorScheme.surface,
                    leading: const Icon(Icons.event),
                    title: Text(
                      context.l10n.add_official_event_select_from_list,
                      style: context.textTheme.titleMedium,
                    ),
                    onTap: () => transitPage(
                      ChooseEventRoute(
                        eventType: EventType.official,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    tileColor: context.colorScheme.surface,
                    leading: const Icon(Icons.event),
                    title: Text(
                      context.l10n.add_unofficial_event_select_from_list,
                      style: context.textTheme.titleMedium,
                    ),
                    onTap: () => transitPage(
                      ChooseEventRoute(
                        eventType: EventType.unofficial,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    tileColor: context.colorScheme.surface,
                    leading: const Icon(Icons.public),
                    title: Text(
                      context.l10n.add_event_create_public,
                      style: context.textTheme.titleMedium,
                    ),
                    onTap: () => transitPage(CreateEventRoute(
                        createEventType: CreateEventType.public)),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    tileColor: context.colorScheme.surface,
                    leading: const Icon(Icons.lock),
                    title: Text(
                      context.l10n.add_event_create_private,
                      style: context.textTheme.titleMedium,
                    ),
                    onTap: () => transitPage(CreateEventRoute(
                        createEventType: CreateEventType.private)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  static Future<void> show(BuildContext context) async => showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => const AddEventBottomSheet());
}
