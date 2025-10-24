import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/context_extension.dart';

class LincaVerticalBack extends StatelessWidget {
  const LincaVerticalBack({
    super.key,
    this.animationTag = '',
  });

  final String animationTag;
  static final List<String> days = <String>['月', '火', '水', '木', '金', '土', '日'];

  static final List<double> weeklyData = <double>[30, 45, 28, 60, 90, 55, 40];

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = context.theme.brightness == Brightness.light
        ? context.colorScheme.surface
        : context.colorScheme.surfaceContainer;

    Widget getBottomTitle(double value, TitleMeta meta) {
      final String day = days[value.toInt()];
      return SideTitleWidget(
        meta: meta,
        child: Text(
          day,
          style: context.textTheme.bodyMedium,
        ),
      );
    }

    return Hero(
      tag: animationTag,
      child: Material(
        color: Colors.transparent,
        child: SizedBox.expand(
          child: _buildCard(context, backgroundColor, getBottomTitle),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    Color backgroundColor,
    GetTitleWidgetFunction getBottomTitle,
  ) =>
      Card(
        color: backgroundColor,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 72, 8, 16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(getTooltipItem: (
                  BarChartGroupData group,
                  int groupIndex,
                  BarChartRodData rod,
                  int rodIndex,
                ) {
                  return BarTooltipItem(
                    '${days[group.x]}: ${rod.toY.toInt()}万円',
                    const TextStyle(color: Colors.white, fontSize: 10),
                  );
                }),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    reservedSize: 30,
                    showTitles: true,
                    getTitlesWidget: getBottomTitle,
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                  ),
                ),
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                    reservedSize: 30,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups:
                  weeklyData.asMap().entries.map((MapEntry<int, double> entry) {
                final int index = entry.key;
                final double value = entry.value;
                return BarChartGroupData(x: index, barRods: <BarChartRodData>[
                  BarChartRodData(
                      toY: value, width: 20, color: Colors.blueAccent),
                ]);
              }).toList(),
            ),
          ),
        ),
      );
}
