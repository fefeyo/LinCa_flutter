import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/network/model/tag.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/linca_event_extension.dart';
import 'package:linca_otaku_support/core/utils/tag_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';

import '../data/highlight_state.dart';
import '../view_model/highlight_view_model.dart';

class SeriesGraphPage extends HookConsumerWidget {
  const SeriesGraphPage({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey repaintKey = GlobalKey();
    final HighlightState state = ref.watch(highlightViewModelProvider);

    final List<Tag> seriesTags =
        (ref
            .read(tagControllerProvider)
            .value ?? <Tag>[]).seriesTags;

    final Map<String, int> counts =
        state.filteredMyEvents.seriesParticipationCounts;

    final List<PieChartSectionData> sections = seriesTags
        .map((Tag tag) {
      final int count = counts[tag.slug] ?? 0;
      if (count == 0) return null;

      return PieChartSectionData(
        color: tag.getSeriesColor(context),
        value: count.toDouble(),
        title: '$count',
        radius: 100,
        titleStyle: context.textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    })
        .whereType<PieChartSectionData>()
        .toList();

    return Stack(
      children: <Widget>[
        Positioned(
          top: 32,
          left: 0,
          right: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: RepaintBoundary(
              key: repaintKey,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width - 32,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            context.colorScheme.surface,
                            context.colorScheme.surfaceContainerHighest,
                          ],
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[

                          /// ---------- 見出し ----------
                          Text(
                            context.l10n.highlight_series_breakdown_title(
                              state.selectedYear,
                            ),
                            style: context.textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                              context.l10n.common_count(
                                state.filteredMyEvents.officialEventCount,
                              ),
                              style: context.textTheme.headlineMedium),
                          const SizedBox(height: 16),
                          Text(
                            context.l10n.highlight_series_breakdown_subtitle,
                            style: context.textTheme.titleMedium
                                ?.copyWith(color: Colors.grey),
                          ),

                          /// ---------- グラフ ----------
                          SizedBox(
                            height: 300,
                            child: PieChart(
                              PieChartData(
                                sections: sections,
                                centerSpaceRadius: 40,
                                sectionsSpace: 3,
                                borderData: FlBorderData(show: false),
                              ),
                            ),
                          ),

                          /// ---------- 凡例 ----------
                          Column(
                            children: seriesTags.map((Tag tag) {
                              final int count = counts[tag.slug] ?? 0;
                              if (count == 0) return const SizedBox.shrink();

                              return Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: tag.getSeriesColor(context),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        tag.name,
                                        style: context.textTheme.labelSmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '$count回',
                                      style: context.textTheme.labelSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                          const Spacer(),

                          Text(
                            context.l10n.highlight_generated_sign,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.router.pop(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        context.l10n.highlight_end,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// ---------- 戻る ----------
        Positioned(
          top: 0,
          left: 0,
          child: BackButton(onPressed: onBack),
        ),

        /// ---------- シェア ----------
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final Uint8List png = await _capture(repaintKey);
              if (!context.mounted) return;
              await _shareImage(context: context, pngBytes: png);
            },
          ),
        ),
      ],
    );
  }

  Future<Uint8List> _capture(GlobalKey key) async {
    final RenderRepaintBoundary boundary =
    key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 3);
    final ByteData byteData =
    (await image.toByteData(format: ui.ImageByteFormat.png))!;
    return byteData.buffer.asUint8List();
  }

  Future<void> _shareImage(
      {required BuildContext context, required Uint8List pngBytes,}) async {
    final XFile file = XFile.fromData(
      pngBytes,
      mimeType: 'image/png',
      name: 'linca_highlight.png',
    );
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[file],
        text: context.l10n.highlight_share_message,
      ),
    );
  }
}
