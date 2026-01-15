import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/analytics_screen.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/event_analytics_manager.dart';
import 'package:linca_otaku_support/core/utils/linca_event_extension.dart';
import 'package:linca_otaku_support/core/utils/participation_extension.dart';
import 'package:linca_otaku_support/features/highlight/data/highlight_state.dart';
import 'package:linca_otaku_support/features/highlight/view_model/highlight_view_model.dart';

import '../../../core/models/linca_event.dart';
import '../../../core/utils/screen_analytics_manager.dart';

class EventCountPage extends HookConsumerWidget
    with ScreenAnalyticsManager, EventAnalyticsManager {
  const EventCountPage({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logScreen(AnalyticsScreen.highlightEventCount);

    final HighlightState state = ref.watch(highlightViewModelProvider);
    final List<LincaEvent> participatedEvents = state.filteredMyEvents
        .where(
          (LincaEvent event) => state.participations.hasEventId(event.event.id),
    )
        .toList();

    return Stack(
      children: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  context.l10n.highlight_total_title(state.selectedYear),
                  style: context.textTheme.titleMedium?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  context.l10n.common_count(participatedEvents.length),
                  style: context.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 32),

                // 内訳カード
                Row(
                  children: <Widget>[
                    _CountCard(
                      label: context.l10n.common_official_event,
                      count: participatedEvents.officialEventCount,
                      icon: Icons.verified,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    _CountCard(
                      label: context.l10n.common_original_event,
                      count: participatedEvents.unofficialEventCount,
                      icon: Icons.favorite,
                      color: Colors.pink,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Next ボタン
        Positioned(
          left: 24,
          right: 24,
          bottom: 16,
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              context.l10n.common_next,
              style: context.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // 戻る
        Positioned(
          top: 8,
          left: 8,
          child: BackButton(onPressed: onBack),
        ),
      ],
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: <Widget>[
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                '$count',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: context.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
