import 'package:auto_route/auto_route.dart';
import 'package:fefeyo_flutter_template/core/router/app_router.gr.dart';
import 'package:fefeyo_flutter_template/core/utils/context_extension.dart';
import 'package:flutter/material.dart';

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
          maxHeight: 320,
        ),
        child: Column(
          children: <Widget>[
            Text(
              'イベントを追加する',
              style: context.textTheme.headlineMedium,
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  ListTile(
                    tileColor: context.colorScheme.surface,
                    leading: const Icon(Icons.event),
                    title: Text(
                      'イベント一覧から選択',
                      style: context.textTheme.titleMedium,
                    ),
                    onTap: () => transitPage(const ChooseEventRoute()),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    tileColor: context.colorScheme.surface,
                    leading: const Icon(Icons.public),
                    title: Text(
                      '公開イベントを作成',
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
                      '非公開イベントを作成',
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
