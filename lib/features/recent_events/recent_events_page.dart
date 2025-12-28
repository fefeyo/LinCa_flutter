import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/utils/date_extension.dart';

import '../../core/router/app_router.gr.dart';
import '../../core/utils/context_extension.dart';
import '../../core/models/linca_event.dart';
import '../../core/network/providers.dart';
import '../../core/widgets/event/event_card.dart';

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

        // 今日から 3 ヶ月後（90 日でも OK）
        final DateTime threeMonthsLater = now.add(const Duration(days: 90));

        // 今日以降かつ 3 ヶ月以内のイベントだけ抽出
        final List<LincaEvent> upcomingEvents = lincaEvents
            .where((LincaEvent event) {
          final DateTime? date = event.event.date;
          if (date == null) return false;
          return (date.isAfter(now) && date.isBefore(threeMonthsLater)) ||
              date.isSameDate(now);
        }).toList()
          ..sort((LincaEvent a, LincaEvent b) =>
              a.event.date!.compareTo(b.event.date!));

        return CustomScrollView(
          slivers: <Widget>[
            // スクロール可能なイベントリスト
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final LincaEvent event = upcomingEvents[index];
                  final ParticipationInfo? participationInfo =
                      participations[event];
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      8,
                      index == 0 ? 8 : 6, // ← 最初の要素だけ上に多めの余白を取る
                      8,
                      6,
                    ),
                    child: EventCard(
                      lincaEvent: event,
                      onClick: () => context.router.push(
                        EventDetailRoute(
                          lincaEvent: event,
                          participationInfo: participationInfo,
                        ),
                      ),
                      participationInfo: participationInfo,
                    ),
                  );
                },
                childCount: upcomingEvents.length,
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
