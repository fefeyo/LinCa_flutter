import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';

import '../../core/utils/context_extension.dart';
import '../../core/models/linca_event.dart';
import '../../core/network/providers.dart';
import '../../core/widgets/event/event_card.dart';
import 'view/fixed_header_delegate.dart';
import 'view/on_the_day_event.dart';

@RoutePage()
class RecentEventsPage extends HookConsumerWidget {
  const RecentEventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<LincaEvent>> events =
        ref.watch(eventControllerProvider);
    final Map<LincaEvent, ParticipationInfo> participations =
        ref.watch(participationControllerProvider).value ??
            <LincaEvent, ParticipationInfo>{};

    Widget generateEventList() {
      if (events is AsyncData<List<LincaEvent>>) {
        final List<LincaEvent> lincaEvents = events.value;
        // 今日の日付
        final DateTime now = DateTime.now();
        final DateTime today = DateTime(now.year, now.month, now.day);
        // final DateTime today = DateTime(2025, 11, 8); // デバッグ用

        // 本日開催イベントを抽出
        final List<LincaEvent> todayEvents =
            lincaEvents.where((LincaEvent event) {
          final DateTime? date = event.event.date;
          if (date == null) return false;

          final DateTime eventDate = DateTime(date.year, date.month, date.day);
          return eventDate == today;
        }).toList();

        // 本日以降のイベント（今日を含む）を取得 → ソート
        final List<LincaEvent> upcomingEvents = lincaEvents
            .where((LincaEvent event) => event.event.date?.isAfter(now) == true)
            .toList()
          ..sort((LincaEvent a, LincaEvent b) =>
              a.event.date!.compareTo(b.event.date!));

        // todayEvents に含まれないイベントだけ残す
        final List<LincaEvent> displayEvents = upcomingEvents
            .where((LincaEvent event) => !todayEvents.contains(event))
            .take(10)
            .toList();

        // Map<LincaEvent, ParticipationInfo?> の生成
        final Map<LincaEvent, ParticipationInfo?> participationEventMap =
            <LincaEvent, ParticipationInfo?>{
          for (final LincaEvent event in todayEvents)
            event: participations[event],
        };

        return CustomScrollView(
          slivers: <Widget>[
            // 上部に固定される SliverPersistentHeader
            if (participationEventMap.isNotEmpty)
              SliverPersistentHeader(
                pinned: true,
                delegate: FixedHeaderDelegate(
                  child: OnTheDayEvent(events: participationEventMap),
                  height: 240,
                ),
              ),

            // スクロール可能なイベントリスト
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final LincaEvent event = displayEvents[index];
                  final ParticipationInfo? participationInfo =
                      participations[event];
                  return Padding(
                    padding:
                        EdgeInsets.fromLTRB(
                          16,
                          index == 0 ? 8 : 6, // ← 最初の要素だけ上に多めの余白を取る
                          16,
                          6,
                        ),
                    child: EventCard(
                      lincaEvent: event,
                      participationInfo: participationInfo,
                    ),
                  );
                },
                childCount: displayEvents.length,
              ),
            ),
          ],
        );
      }

      if (events is AsyncError<List<LincaEvent>>) {
        return Center(
          child: Column(
            children: <Widget>[
              Text(
                'エラーが発生しました\n${events.error}',
                style: context.textTheme.headlineMedium,
              ),
              ElevatedButton(
                onPressed: () => ref.refresh(eventControllerProvider),
                child: const Text('再読み込み'),
              ),
            ],
          ),
        );
      }

      if (events is AsyncLoading<List<LincaEvent>>) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return const SizedBox.shrink();
    }

    return generateEventList();
  }
}
