import 'package:flutter_test/flutter_test.dart';
import 'package:linca_otaku_support/core/models/event_details_mapper.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/network/model/event_base.dart';
import 'package:linca_otaku_support/core/network/model/group.dart';
import 'package:linca_otaku_support/core/network/model/tag.dart';
import 'package:linca_otaku_support/core/network/model/venue.dart';

void main() {
  const Tag first = Tag(id: 'a', order: 2);
  const Tag last = Tag(id: 'a', name: 'last', order: 3);
  const Tag second = Tag(id: 'b', order: 1);
  final EventDetailsMapper mapper = EventDetailsMapper(
    tags: <Tag>[first, last, second],
    venues: <Venue>[
      const Venue(id: 'v', name: 'old'),
      const Venue(id: 'v', name: 'new'),
    ],
    groups: <Group>[
      const Group(slug: 'g', name: 'old'),
      const Group(slug: 'g', name: 'new'),
    ],
  );
  const OfficialEvent official = OfficialEvent(
    id: 'official',
    venueId: 'v',
    organizer: 'g',
    tagIds: <String>['a', 'missing', 'b', 'a'],
  );

  test('official joins use last references and skip missing tags', () {
    final LincaEvent result = mapper.official(official);
    expect(result.event, same(official));
    expect(result.tags, <Tag>[last, second, last]);
    expect(result.venue.name, 'new');
    expect(result.group.name, 'new');
  });

  test('initial official tags sort by order; refresh preserves ID order', () {
    expect(mapper.official(official, sortTags: true).tags,
        <Tag>[second, last, last]);
    expect(mapper.official(official).tags, <Tag>[last, second, last]);
    expect(official.tagIds, <String>['a', 'missing', 'b', 'a']);
  });

  test('missing venue and group retain empty model fallbacks', () {
    final LincaEvent result = mapper.official(const OfficialEvent());
    expect(result.venue, const Venue());
    expect(result.group, const Group());
    expect(result.tags, isEmpty);
  });

  test('unofficial joins use first references and preserve duplicate IDs', () {
    const UnOfficialEvent event = UnOfficialEvent(
      tagIds: <String>['a', 'missing', 'b', 'a'],
    );
    final LincaEvent result =
        EventDetailsMapper.unofficial(event, <Tag>[first, last, second]);
    expect(result.event, same(event));
    expect(result.tags, <Tag>[first, second, first]);
    expect(result.venue, const Venue());
    expect(result.group, const Group());
  });
}
