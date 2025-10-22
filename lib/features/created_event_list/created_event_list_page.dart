import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/network/controller/user_event_controller.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/widgets/common/common_simple_dialog.dart';

import '../../core/models/linca_event.dart';
import '../../core/widgets/event/event_card.dart';
import 'data/created_event_list_state.dart';
import 'view_model/created_event_list_view_model.dart';

@RoutePage()
class CreatedEventListPage extends HookConsumerWidget {
  const CreatedEventListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CreatedEventListState state =
        ref.watch(createdEventListViewModelProvider);
    final UserEventController userEventController =
        ref.read(userEventControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('作成済みイベント一覧')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: state.events.isNotEmpty
            ? ListView.separated(
                itemCount: state.events.length,
                itemBuilder: (BuildContext context, int index) {
                  final LincaEvent event = state.events[index];
                  return _buildEventCardWithDelete(
                    context: context,
                    event: event,
                    onDelete: () =>
                        userEventController.deleteEvent(event: event),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 12),
              )
            : Center(
                child: Text(
                  '作成したイベントがありません',
                  style: context.textTheme.titleMedium,
                ),
              ),
      ),
    );
  }

  Widget _buildEventCardWithDelete({
    required BuildContext context,
    required LincaEvent event,
    required Function() onDelete,
  }) {
    return Stack(
      children: <Widget>[
        EventCard(lincaEvent: event),
        Positioned(
          bottom: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'イベントを削除',
            onPressed: () async {
              final bool? confirmed = await CommonSimpleDialog.show(
                context: context,
                title: '削除の確認',
                content: 'このイベントを削除しますか？',
                cancelText: context.l10n.common_cancel,
                okText: '削除する',
              );

              if (confirmed == true) {
                onDelete();
              }
            },
          ),
        ),
      ],
    );
  }
}
