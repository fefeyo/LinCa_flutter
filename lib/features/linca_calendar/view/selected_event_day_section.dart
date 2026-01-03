import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/features/linca_calendar/view/selected_event_day_empty.dart';
import 'package:linca_otaku_support/features/linca_calendar/view/selected_event_day_section_event_list.dart';

import '../../../core/models/linca_event.dart';
import '../../../core/utils/context_extension.dart';

class SelectedDayEventSection extends StatelessWidget {
  const SelectedDayEventSection({
    super.key,
    required this.selectedDate,
    required this.events,
  });

  final DateTime? selectedDate;
  final Map<LincaEvent, ParticipationInfo?> events;

  @override
  Widget build(BuildContext context) {
    if (selectedDate == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: <Widget>[
        const SizedBox(height: 16),
        Text(
          '${selectedDate?.month}月${selectedDate?.day}日 のイベント',
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: events.isNotEmpty
              ? SelectedEventDaySectionEventList(events: events)
              : const SelectedEventDayEmpty(),
        ),
      ],
    );
  }
}
