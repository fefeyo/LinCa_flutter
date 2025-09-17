import 'package:auto_route/auto_route.dart';
import 'package:fefeyo_flutter_template/core/constants/participation_type.dart';
import 'package:fefeyo_flutter_template/core/router/app_router.gr.dart';
import 'package:fefeyo_flutter_template/core/utils/date_extention.dart';
import 'package:fefeyo_flutter_template/core/utils/participation_type_extension.dart';
import 'package:fefeyo_flutter_template/core/widgets/event/participation_status_badge.dart';
import 'package:flutter/material.dart';

import '../../asset_gen/assets.gen.dart';
import '../../models/linca_event.dart';
import '../../network/model/tag.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.lincaEvent,
  });

  final LincaEvent lincaEvent;

  // TODO: Participationテーブル参照して、参加タイプを取得する
  final ParticipationType dummyType = ParticipationType.none;

  Color _badgeColor(BuildContext context) {
    switch (dummyType) {
      case ParticipationType.none:
        return Colors.transparent;
      case ParticipationType.onSite:
        return Colors.red;
      case ParticipationType.streaming:
        return Colors.blue;
      case ParticipationType.liveViewing:
        return Colors.orange;
      case ParticipationType.absent:
        return Colors.purple;
    }
  }

  String _badgeLabel(BuildContext context) => dummyType.label(context);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          ListTile(
            contentPadding: const EdgeInsetsGeometry.symmetric(
                vertical: 12, horizontal: 16),
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(Assets.images.userIcon.path),
              backgroundColor: Colors.transparent,
            ),
            title: Text(
              lincaEvent.event.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  lincaEvent.event.date?.simpleDateFormat() ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(
                  height: 4,
                ),
                Wrap(
                  spacing: 4,
                  children: lincaEvent.tags.map((Tag tag) {
                    return Chip(
                      label: Text(
                        tag.name,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.router
                    .push(EventDetailRoute(lincaEvent: lincaEvent)),
              ),
            ),
          ),
          if (dummyType != ParticipationType.none)
            Positioned(
              right: 0,
              top: -12,
              child: Row(
                children: <Widget>[
                  const ParticipationStatusBadge(
                    text: '参加予定',
                    color: Colors.green,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  ParticipationStatusBadge(
                    text: _badgeLabel(context),
                    color: _badgeColor(context),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
