import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/network/model/group.dart';
import 'package:linca_otaku_support/core/utils/group_extension.dart';
import 'package:linca_otaku_support/core/widgets/common/common_close_button.dart';
import 'package:linca_otaku_support/features/linca_detail/data/participation_graph_threshold.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/context_extension.dart';

class LincaVerticalBack extends HookConsumerWidget {
  const LincaVerticalBack({
    super.key,
    required this.participationEvents,
    this.animationTag = '',
    this.onClickFlip,
    this.onClickClose,
  });

  final List<LincaEvent> participationEvents;
  final String animationTag;
  final Function()? onClickFlip;
  final Function()? onClickClose;

  static const List<String> _groupNames = <String>[
    "μ's",
    'Aqours',
    '虹ヶ咲',
    'Lialla!',
    '蓮ノ空',
    'いきづ\nらい部！',
  ];

  static final List<Group> _groups = <Group>[
    const Group(seriesTag: AppConstants.seriesTagLovelive),
    const Group(seriesTag: AppConstants.seriesTagSunshine),
    const Group(seriesTag: AppConstants.seriesTagNijigasaki),
    const Group(seriesTag: AppConstants.seriesTagSuperstar),
    const Group(seriesTag: AppConstants.seriesTagHasunosora),
    const Group(seriesTag: AppConstants.seriesTagIkizulive),
  ];

  Map<Group, int> getEventParticipationData(List<LincaEvent> events) {
    final Map<Group, int> counts = <Group, int>{
      for (final Group group in _groups) group: 0,
    };

    for (final LincaEvent event in events) {
      for (final Group group in _groups) {
        if (event.group.seriesTag == group.seriesTag) {
          counts[group] = counts[group]! + 1;
        }
      }
    }

    return counts;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color backgroundColor = context.theme.brightness == Brightness.light
        ? context.colorScheme.surface
        : context.colorScheme.surfaceContainer;
    final ValueNotifier<ParticipationGraphThreshold> graphThreshold =
        useState(ParticipationGraphThreshold.ten());

    Widget getBottomTitle(double value, TitleMeta meta) {
      final String day = _groupNames[value.toInt()];
      return SideTitleWidget(
        meta: meta,
        child: Text(
          day,
          style: context.textTheme.labelSmall,
        ),
      );
    }

    return Hero(
      tag: animationTag,
      child: Material(
        color: Colors.transparent,
        child: SizedBox.expand(
          child: _buildCard(
            context: context,
            backgroundColor: backgroundColor,
            getBottomTitle: getBottomTitle,
            graphThreshold: graphThreshold.value,
            onChangeThreshold: (ParticipationGraphThreshold newValue) {
              graphThreshold.value = newValue;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required Color backgroundColor,
    required GetTitleWidgetFunction getBottomTitle,
    required ParticipationGraphThreshold graphThreshold,
    required Function(ParticipationGraphThreshold newValue) onChangeThreshold,
  }) =>
      Card(
        color: backgroundColor,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'グループ別イベント参加数',
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      '表示範囲の選択',
                      style: context.textTheme.labelMedium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SegmentedButton<ParticipationGraphThreshold>(
                        showSelectedIcon: false,
                        segments: <ButtonSegment<ParticipationGraphThreshold>>[
                          for (final ParticipationGraphThreshold threshold
                              in ParticipationGraphThreshold
                                  .participationGraphThresholdList)
                            ButtonSegment<ParticipationGraphThreshold>(
                              value: threshold,
                              label: Text(threshold.label),
                            )
                        ],
                        selected: <ParticipationGraphThreshold>{graphThreshold},
                        onSelectionChanged:
                            (Set<ParticipationGraphThreshold> newSelection) {
                          if (newSelection.isNotEmpty) {
                            onChangeThreshold(newSelection.first);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: graphThreshold.maxY,
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              reservedSize: 90,
                              showTitles: true,
                              getTitlesWidget: getBottomTitle,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 35,
                              interval: graphThreshold.interval,
                            ),
                          ),
                          rightTitles: const AxisTitles(),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups:
                            getEventParticipationData(participationEvents)
                                .entries
                                .map((MapEntry<Group, int> entry) {
                          final int index = _groups.indexOf(entry.key);
                          final double count = entry.value.toDouble();
                          final LinearGradient gradient =
                              entry.key.getSeriesGradientForGraph(context);
                          return BarChartGroupData(
                            x: index,
                            barRods: <BarChartRodData>[
                              BarChartRodData(
                                toY: count
                                    .clamp(0, graphThreshold.maxY)
                                    .toDouble(),
                                width: 20,
                                gradient: gradient,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: CommonCloseButton(
                onClose: () => onClickClose?.call(),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.sync, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black26,
                  shape: const CircleBorder(),
                  fixedSize: const Size(48, 48),
                  padding: EdgeInsets.zero,
                ),
                onPressed: onClickFlip,
              ),
            ),
          ],
        ),
      );
}
