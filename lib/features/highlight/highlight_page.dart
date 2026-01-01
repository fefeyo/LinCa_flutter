import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/analytics_event.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/event_analytics_manager.dart';

import 'view/event_count_page.dart';
import 'view/series_graph_page.dart';
import 'view/year_select_page.dart';

@RoutePage()
class HighlightPage extends HookConsumerWidget with EventAnalyticsManager {
  const HighlightPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PageController pageController = usePageController();
    final ValueNotifier<int> currentPage = useState(0);

    void onNextPage() {
      logEvent(event: AnalyticsEvent.highlightNextClick);

      if (pageController.hasClients) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    void onBackPage() {
      logEvent(event: AnalyticsEvent.highlightBackClick);

      if (pageController.hasClients) {
        pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    return PopScope(
      canPop: currentPage.value == 0,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;

        pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                context.colorScheme.primary.withValues(alpha: 0.15),
                context.colorScheme.secondary.withValues(alpha: 0.15),
              ],
            ),
          ),
          child: SafeArea(
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (int page) {
                currentPage.value = page;
              },
              children: <Widget>[
                YearSelectPage(
                  onNext: onNextPage,
                ),
                EventCountPage(
                  onNext: onNextPage,
                  onBack: onBackPage,
                ),
                SeriesGraphPage(
                  onNext: onNextPage,
                  onBack: onBackPage,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
