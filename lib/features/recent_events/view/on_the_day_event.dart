import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/widgets/event/event_card.dart';

import '../../../core/models/linca_event.dart';

class OnTheDayEvent extends StatelessWidget {
  const OnTheDayEvent({
    super.key,
    required this.events,
  });

  final Map<LincaEvent, ParticipationInfo?> events;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Colors.orange.shade200, Colors.deepOrange.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.deepOrangeAccent,
            width: 2,
          ),
        ),
        child: Column(
          children: <Widget>[
            Text(
              '🎉🎉🎉 本日開催のイベント！ 🎉🎉🎉',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (final LincaEvent event in events.keys)
              EventCard(
                lincaEvent: event,
                participationInfo: events[event],
              ),
          ],
        ),
      ),
    );
  }
}
