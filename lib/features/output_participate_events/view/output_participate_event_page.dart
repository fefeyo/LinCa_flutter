import 'package:flutter/cupertino.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/date_extension.dart';
import 'package:linca_otaku_support/core/utils/group_extension.dart';

class OutputParticipateEventPage extends StatelessWidget {
  const OutputParticipateEventPage({
    super.key,
    required this.events,
  });

  final List<LincaEvent> events;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: context.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: events.map((LincaEvent entry) {
          final LincaEvent lincaEvent = entry;
          final Color seriesColor = lincaEvent.group.getSeriesColor(context);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: seriesColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _buildEventText(lincaEvent),
                    style: context.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _buildEventText(LincaEvent event) {
    final String dateText = event.event.date?.simpleDateFormat() ?? '';
    return '$dateText ${event.event.title}';
  }
}
