import 'package:auto_route/auto_route.dart';
import 'package:fefeyo_flutter_template/core/constants/participation_type.dart';
import 'package:fefeyo_flutter_template/core/router/app_router.gr.dart';
import 'package:fefeyo_flutter_template/core/utils/participation_type_extension.dart';
import 'package:fefeyo_flutter_template/core/widgets/event/participation_status_badge.dart';
import 'package:flutter/material.dart';

import '../../asset_gen/assets.gen.dart';
import '../../network/model/event.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
  });

  final Event event;

  Color _badgeColor(BuildContext context) {
    switch (event.type) {
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

  String _badgeLabel(BuildContext context) => event.type.label(context);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(vertical: 8, horizontal: 16),
      child: Card(
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
                'ラブライブ！スーパースター Liella! First Gener'
                    'ation LoveLive! ～Wonderful Starlines～',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '8/20(土)〜8/21(日)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Wrap(
                    spacing: 4,
                    children: event.tags.map(
                      (String tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          visualDensity: VisualDensity.compact,
                        );
                      },
                    ).toList(),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () =>
                      context.router.push(EventDetailRoute(event: event)),
                ),
              ),
            ),
            if (event.type != ParticipationType.none)
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
      ),
    );
  }
}
