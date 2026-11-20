import 'package:flutter_test/flutter_test.dart';
import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:linca_otaku_support/core/constants/participation_type.dart';
import 'package:linca_otaku_support/core/models/app_settings.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/network/model/event_base.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/utils/notification/event_notification_plan.dart';

final DateTime today = DateTime(2026, 1, 2);

LincaEvent event(
  String id, {
  bool canceled = false,
  String checkInId = '',
  List<String> tags = const <String>[],
}) =>
    LincaEvent(
        event: OfficialEvent(
      id: id,
      date: today,
      cancelFlg: canceled,
      checkInId: checkInId,
      tagIds: tags,
    ));

List<String> ids(List<LincaEvent> events) =>
    events.map((LincaEvent e) => e.event.id).toList();

void main() {
  final List<LincaEvent> events = <LincaEvent>[
    LincaEvent(event: OfficialEvent(id: 'past', date: DateTime(2026, 1, 1))),
    const LincaEvent(event: OfficialEvent(id: 'undated')),
    event('onsite', checkInId: 'check-in'),
    event('onsite-no-check-in'),
    event('streaming', checkInId: 'check-in'),
    event('absent', tags: <String>[AppConstants.seriesTagLovelive]),
    event('null-type'),
    event('canceled', canceled: true, checkInId: 'check-in'),
    event('unregistered', tags: <String>[AppConstants.seriesTagLovelive]),
  ];
  const List<ParticipationInfo> participations = <ParticipationInfo>[
    ParticipationInfo(
        eventId: 'onsite', participationType: ParticipationType.onSite),
    ParticipationInfo(
        eventId: 'onsite-no-check-in',
        participationType: ParticipationType.onSite),
    ParticipationInfo(
        eventId: 'streaming', participationType: ParticipationType.streaming),
    ParticipationInfo(
        eventId: 'absent', participationType: ParticipationType.absent),
    ParticipationInfo(eventId: 'null-type'),
    ParticipationInfo(
        eventId: 'canceled', participationType: ParticipationType.onSite),
    // The first matching participation still takes precedence.
    ParticipationInfo(
        eventId: 'onsite', participationType: ParticipationType.absent),
  ];

  EventNotificationPlan plan(AppSettings settings) => EventNotificationPlan(
        events: events,
        participations: participations,
        settings: settings,
        now: DateTime(2026, 1, 2, 18),
      );

  test('disabled notifications still cancel today/future, including canceled',
      () {
    final EventNotificationPlan result = plan(const AppSettings());
    expect(ids(result.upcomingEvents), <String>[
      'onsite',
      'onsite-no-check-in',
      'streaming',
      'absent',
      'null-type',
      'canceled',
      'unregistered',
    ]);
    expect(result.targetEvents, isEmpty);
  });

  test('all participation includes null type but not absent or canceled', () {
    expect(
        ids(plan(const AppSettings(
          isNotificationEnabled: true,
          isMyEventNotificationEnabled: true,
        )).targetEvents),
        <String>[
          'onsite',
          'onsite-no-check-in',
          'streaming',
          'null-type',
        ]);
  });

  test('check-in selection requires on-site participation and check-in ID', () {
    expect(
        ids(plan(const AppSettings(
          isNotificationEnabled: true,
          isMyEventNotificationEnabled: true,
          eventNotificationType: EventNotificationType.onlyHasCheckedIn,
        )).targetEvents),
        <String>['onsite']);
  });

  test('all-event selection excludes any registered event, including absent',
      () {
    expect(
        ids(plan(const AppSettings(
          isNotificationEnabled: true,
          isAllEventNotificationEnabled: true,
        )).targetEvents),
        <String>['unregistered']);
    expect(plan(const AppSettings(isNotificationEnabled: true)).targetEvents,
        isEmpty);
  });

  test('my events precede series order; duplicates use full event equality',
      () {
    final LincaEvent shared = event('shared', tags: <String>[
      AppConstants.seriesTagLovelive,
      AppConstants.seriesTagSunshine,
    ]);
    final LincaEvent changed = shared.copyWith(
      event: (shared.event as OfficialEvent).copyWith(title: 'different'),
    );
    final List<LincaEvent> input = <LincaEvent>[
      event('sunshine', tags: <String>[AppConstants.seriesTagSunshine]),
      shared,
      shared,
      changed,
      event('mine'),
    ];
    final EventNotificationPlan result = EventNotificationPlan(
      events: input,
      participations: <ParticipationInfo>[
        const ParticipationInfo(eventId: 'mine'),
      ],
      settings: const AppSettings(
        isNotificationEnabled: true,
        isMyEventNotificationEnabled: true,
        isAllEventNotificationEnabled: true,
      ),
      now: today,
    );
    expect(result.targetEvents, <LincaEvent>[
      input.last,
      shared,
      changed,
      input.first,
    ]);
    expect(input, hasLength(5));
  });

  const AppSettings allDisabled = AppSettings(
    isNotificationEnabled: true,
    isAllEventNotificationEnabled: true,
    isLoveLiveNotificationEnabled: false,
    isSunshineNotificationEnabled: false,
    isNijigasakiNotificationEnabled: false,
    isSuperstarNotificationEnabled: false,
    isHasunosoraNotificationEnabled: false,
    isIkizuliveNotificationEnabled: false,
    isMusicalNotificationEnabled: false,
    isYohaneNotificationEnabled: false,
    isCollaborativeNotificationEnabled: false,
  );
  final List<(String, AppSettings)> seriesSettings = <(String, AppSettings)>[
    (
      AppConstants.seriesTagLovelive,
      allDisabled.copyWith(isLoveLiveNotificationEnabled: true)
    ),
    (
      AppConstants.seriesTagSunshine,
      allDisabled.copyWith(isSunshineNotificationEnabled: true)
    ),
    (
      AppConstants.seriesTagNijigasaki,
      allDisabled.copyWith(isNijigasakiNotificationEnabled: true)
    ),
    (
      AppConstants.seriesTagSuperstar,
      allDisabled.copyWith(isSuperstarNotificationEnabled: true)
    ),
    (
      AppConstants.seriesTagHasunosora,
      allDisabled.copyWith(isHasunosoraNotificationEnabled: true)
    ),
    (
      AppConstants.seriesTagIkizulive,
      allDisabled.copyWith(isIkizuliveNotificationEnabled: true)
    ),
    (
      AppConstants.seriesTagMusical,
      allDisabled.copyWith(isMusicalNotificationEnabled: true)
    ),
    (
      AppConstants.seriesTagYohane,
      allDisabled.copyWith(isYohaneNotificationEnabled: true)
    ),
    (
      AppConstants.seriesTagCollaborative,
      allDisabled.copyWith(isCollaborativeNotificationEnabled: true)
    ),
  ];
  final List<LincaEvent> seriesEvents = seriesSettings
      .map(((String, AppSettings) item) =>
          event(item.$1, tags: <String>[item.$1]))
      .toList();
  for (final (String tag, AppSettings settings) in seriesSettings) {
    test('series flag selects only $tag', () {
      final EventNotificationPlan result = EventNotificationPlan(
        events: seriesEvents,
        participations: <ParticipationInfo>[],
        settings: settings,
        now: today,
      );
      expect(ids(result.targetEvents), <String>[tag]);
    });
  }
}
