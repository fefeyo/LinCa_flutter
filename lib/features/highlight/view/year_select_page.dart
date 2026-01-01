import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/analytics_event.dart';
import 'package:linca_otaku_support/core/constants/analytics_screen.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/event_analytics_manager.dart';
import 'package:linca_otaku_support/core/utils/linca_event_extension.dart';
import 'package:linca_otaku_support/core/utils/screen_analytics_manager.dart';
import 'package:linca_otaku_support/features/highlight/data/highlight_state.dart';
import 'package:linca_otaku_support/features/highlight/view_model/highlight_view_model.dart';

class YearSelectPage extends HookConsumerWidget
    with ScreenAnalyticsManager, EventAnalyticsManager {
  const YearSelectPage({
    super.key,
    required this.onNext,
  });

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logScreen(AnalyticsScreen.highlightYearSelect);

    final HighlightState state = ref.watch(highlightViewModelProvider);
    final HighlightViewModel viewModel =
        ref.read(highlightViewModelProvider.notifier);

    useEffect(() {
      Future<void>.microtask(() async {
        if (!context.mounted) return;
        if (state.selectedYear.isEmpty &&
            state.myEvents.selectableYears.isNotEmpty) {
          viewModel.setSelectedYear(state.myEvents.selectableYears.first);
        }
      });
      return null;
    }, const <Object?>[]);

    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // タイトル
                Text(
                  context.l10n.highlight_title,
                  style: context.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  context.l10n.highlight_choose_year_description,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),

                const SizedBox(height: 32),

                // 年選択カード
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: <Widget>[
                          Text(
                            context.l10n.highlight_choose_year_target,
                            style: context.textTheme.titleSmall?.copyWith(
                              color: context.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: state.selectedYear.isEmpty
                                  ? null
                                  : state.selectedYear,
                              isDense: false,
                              style: context.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.colorScheme.primary,
                              ),
                              icon: const Icon(Icons.expand_more),
                              items: state.myEvents.selectableYears
                                  .map(
                                    (String year) => DropdownMenuItem<String>(
                                      value: year,
                                      child:
                                          Text(context.l10n.common_year(year)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (String? year) {
                                logEvent(
                                  event: AnalyticsEvent.yearSelectSelectYear,
                                  params: <String, Object>{
                                    'selectedYear': year ?? 'no value selected'
                                  },
                                );

                                if (year != null) {
                                  viewModel.setSelectedYear(year);
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.l10n.highlight_choose_year_message,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 閉じるボタン
        Positioned(
          top: 0,
          left: 0,
          child: CloseButton(
            onPressed: () => context.router.pop(),
          ),
        ),

        // 下部ボタン
        Positioned(
          left: 24,
          right: 24,
          bottom: 16,
          child: ElevatedButton(
            onPressed: state.selectedYear.isNotEmpty ? onNext : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              context.l10n.common_start,
              style: context.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
