import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/event_type.dart';
import 'package:linca_otaku_support/core/models/filter_settings.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/network/model/event_base.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/network/model/tag.dart';
import 'package:linca_otaku_support/core/utils/event_filter.dart';
import 'package:linca_otaku_support/core/utils/linca_event_extension.dart';
import 'package:linca_otaku_support/core/utils/sort_items_extension.dart';
import 'package:linca_otaku_support/features/choose_event/view_model/choose_event_view_model.dart';
import 'package:linca_otaku_support/features/my_event/view_model/my_event_view_model.dart';
import 'package:linca_otaku_support/features/output_participate_events/view_model/output_participate_events_view_model.dart';

List<String> ids(List<LincaEvent> events) =>
    events.map((LincaEvent e) => e.event.id).toList();

void main() {
  const Tag type = Tag(id: 'type');
  const Tag series = Tag(id: 'series');
  final DateTime day = DateTime(2026, 1, 2);
  final List<LincaEvent> events = <LincaEvent>[
    LincaEvent(event: OfficialEvent(id: 'old', date: DateTime(2026, 1, 1))),
    const LincaEvent(event: OfficialEvent(id: 'undated')),
    LincaEvent(
      event: OfficialEvent(id: 'a', title: 'LIVE', date: day),
      tags: <Tag>[type, series],
    ),
    LincaEvent(
      event: UnOfficialEvent(id: 'b', title: 'live', date: day),
      tags: <Tag>[type, series],
    ),
    LincaEvent(event: OfficialEvent(id: 'c', kana: 'ライブ', date: day)),
  ];

  for (final DisplayOrder order in DisplayOrder.values) {
    test('sort $order keeps null dates last and does not mutate source', () {
      final List<LincaEvent> original = List<LincaEvent>.of(events);
      expect(
          ids(events.sortWithDisplayOrder(displayOrder: order)),
          order == DisplayOrder.newest
              ? <String>['c', 'b', 'a', 'old', 'undated']
              : <String>['old', 'a', 'b', 'c', 'undated']);
      expect(events, original);
    });
  }

  test('same calendar day sorts by ID, not time of day', () {
    final List<LincaEvent> sameDay = <LincaEvent>[
      LincaEvent(event: OfficialEvent(id: 'a', date: DateTime(2026, 1, 2, 23))),
      LincaEvent(event: OfficialEvent(id: 'z', date: day)),
    ];
    expect(ids(sameDay.sortWithDisplayOrder()), <String>['z', 'a']);
  });

  test('period, tag groups and keyword are intersected with inclusive bounds',
      () {
    final FilterSettings settings = FilterSettings(
      startDate: day,
      endDate: day,
      typeTags: <Tag>[type],
      seriesTags: <Tag>[series],
      keyword: 'LiVe absent',
      displayOrder: DisplayOrder.oldest,
    );
    expect(ids(events.applyFilterSettings(settings)), <String>['a', 'b']);
    expect(
        events.applyFilterSettings(settings.copyWith(keyword: '  ')), isEmpty);
    expect(
        ids(events.applyFilterSettings(const FilterSettings(keyword: 'ライブ'))),
        <String>['c']);
    expect(
        ids(events.applyFilterSettings(const FilterSettings(keyword: 'OLD'))),
        <String>['old']);
    expect(
        events.applyFilterSettings(const FilterSettings(
          typeTags: <Tag>[Tag(id: 'type', name: 'different')],
        )),
        isEmpty);
  });

  test('choose-event keeps type filtering separate from common filters', () {
    final Provider<ChooseEventViewModel> provider =
        Provider<ChooseEventViewModel>((Ref ref) =>
            ChooseEventViewModel(ref, events, <ParticipationInfo>[]));
    final ProviderContainer container = ProviderContainer();
    final ChooseEventViewModel choose = container.read(provider);
    addTearDown(container.dispose);
    addTearDown(choose.dispose);
    choose.setEventType(EventType.official);
    choose.setFilterSettings(FilterSettings(
      startDate: day,
      typeTags: <Tag>[type],
      seriesTags: <Tag>[series],
    ));
    choose.setKeyword('LIVE');
    expect(ids(choose.state.sortedEvents), <String>['a']);
    expect(choose.state.filterSettings.keyword, 'LIVE');
    choose.setEventType(EventType.unofficial);
    choose.setKeyword('live');
    expect(ids(choose.state.sortedEvents), <String>['b']);
  });

  // Lock down all combinations, including the existing no-flags fallback.
  for (final bool hidden in <bool>[false, true]) {
    for (final bool official in <bool>[false, true]) {
      for (final bool original in <bool>[false, true]) {
        test('visibility hidden=$hidden official=$official original=$original',
            () {
          final FilterSettings settings = FilterSettings(
            isHiddenOriginalEvent: hidden,
            isShowOfficialEvent: official,
            isShowOriginalEvent: original,
          );
          final List<String> expected = !official && !original
              ? <String>['c', 'b', 'a', 'old', 'undated']
              : original
                  ? (hidden || official ? <String>[] : <String>['b'])
                  : <String>['c', 'a', 'old', 'undated'];
          final MyEventViewModel mine =
              MyEventViewModel(events, <ParticipationInfo>[]);
          final OutputParticipateEventsViewModel output =
              OutputParticipateEventsViewModel(events, <ParticipationInfo>[]);
          addTearDown(mine.dispose);
          addTearDown(output.dispose);
          expect(ids(mine.sortEvents(filterSettings: settings)), expected);
          expect(ids(output.sortEvents(settings)), expected);
        });
      }
    }
  }

  test('keyword setters apply the same settings and retain other filters', () {
    final MyEventViewModel mine =
        MyEventViewModel(events, <ParticipationInfo>[]);
    final OutputParticipateEventsViewModel output =
        OutputParticipateEventsViewModel(events, <ParticipationInfo>[]);
    addTearDown(mine.dispose);
    addTearDown(output.dispose);
    const FilterSettings settings = FilterSettings(
      displayOrder: DisplayOrder.oldest,
      isShowOfficialEvent: true,
    );
    mine.setFilterSettings(settings);
    output.setFilterSettings(settings);
    mine.setKeyword('LIVE');
    output.setKeyword('LIVE');
    expect(mine.state.filterSettings, settings.copyWith(keyword: 'LIVE'));
    expect(output.state.filterSettings, mine.state.filterSettings);
    expect(ids(mine.state.sortedEvents), <String>['a']);
    expect(output.state.sortedEvents, mine.state.sortedEvents);
  });

  test('empty explicit target retains the existing my-event fallback', () {
    final MyEventViewModel mine =
        MyEventViewModel(events, <ParticipationInfo>[]);
    addTearDown(mine.dispose);
    expect(
        mine.sortEvents(
            filterSettings: const FilterSettings(), targetList: <LincaEvent>[]),
        events.sortWithDisplayOrder());
  });
}
