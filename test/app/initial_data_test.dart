import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/app/initial_data.dart';
import 'package:linca_otaku_support/core/local/controller/calendar_event_controller.dart';
import 'package:linca_otaku_support/core/local/models/calendar_event.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/models/linca_user.dart';
import 'package:linca_otaku_support/core/network/controller/badge_controller.dart';
import 'package:linca_otaku_support/core/network/controller/event_controller.dart';
import 'package:linca_otaku_support/core/network/controller/group_controller.dart';
import 'package:linca_otaku_support/core/network/controller/participation_controller.dart';
import 'package:linca_otaku_support/core/network/controller/tag_controller.dart';
import 'package:linca_otaku_support/core/network/controller/user_controller.dart';
import 'package:linca_otaku_support/core/network/controller/user_event_controller.dart';
import 'package:linca_otaku_support/core/network/controller/venue_controller.dart';
import 'package:linca_otaku_support/core/network/model/group.dart';
import 'package:linca_otaku_support/core/network/model/linca_badge.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/network/model/tag.dart';
import 'package:linca_otaku_support/core/network/model/venue.dart';
import 'package:linca_otaku_support/core/network/providers.dart';

class _Gate<T> {
  _Gate(this.name, this.started);
  final String name;
  final List<String> started;
  final Completer<T> completer = Completer<T>();

  Future<T> load() {
    started.add(name);
    return completer.future;
  }
}

class _BadgeController extends BadgeController {
  _BadgeController(this.gate);
  final _Gate<List<LincaBadge>> gate;
  @override
  Future<List<LincaBadge>> build() => gate.load();
}

class _GroupController extends GroupController {
  _GroupController(this.gate);
  final _Gate<List<Group>> gate;
  @override
  Future<List<Group>> build() => gate.load();
}

class _TagController extends TagController {
  _TagController(this.gate);
  final _Gate<List<Tag>> gate;
  @override
  Future<List<Tag>> build() => gate.load();
}

class _VenueController extends VenueController {
  _VenueController(this.gate);
  final _Gate<List<Venue>> gate;
  @override
  Future<List<Venue>> build() => gate.load();
}

class _UserController extends UserController {
  _UserController(this.gate);
  final _Gate<LincaUser> gate;
  @override
  Future<LincaUser> build() => gate.load();
}

class _EventController extends EventController {
  _EventController(this.gate);
  final _Gate<List<LincaEvent>> gate;
  @override
  Future<List<LincaEvent>> build() => gate.load();
}

class _UserEventController extends UserEventController {
  _UserEventController(this.gate);
  final _Gate<List<LincaEvent>> gate;
  @override
  Future<List<LincaEvent>> build() => gate.load();
}

class _ParticipationController extends ParticipationController {
  _ParticipationController(this.gate);
  final _Gate<List<ParticipationInfo>> gate;
  @override
  Future<List<ParticipationInfo>> build() => gate.load();
}

class _CalendarEventController extends CalendarEventController {
  _CalendarEventController(this.gate);
  final _Gate<List<CalendarEvent>> gate;
  @override
  Future<List<CalendarEvent>> build() => gate.load();
}

void main() {
  for (final bool failReferenceData in <bool>[false, true]) {
    test('startup preserves dependency phases (failure=$failReferenceData)',
        () async {
      final List<String> started = <String>[];
      final _Gate<List<LincaBadge>> badge =
          _Gate<List<LincaBadge>>('badge', started);
      final _Gate<List<Group>> group = _Gate<List<Group>>('group', started);
      final _Gate<List<Tag>> tag = _Gate<List<Tag>>('tag', started);
      final _Gate<List<Venue>> venue = _Gate<List<Venue>>('venue', started);
      final _Gate<LincaUser> user = _Gate<LincaUser>('user', started);
      final _Gate<List<LincaEvent>> event =
          _Gate<List<LincaEvent>>('event', started);
      final _Gate<List<LincaEvent>> userEvent =
          _Gate<List<LincaEvent>>('userEvent', started);
      final _Gate<List<ParticipationInfo>> participation =
          _Gate<List<ParticipationInfo>>('participation', started);
      final _Gate<List<CalendarEvent>> calendar =
          _Gate<List<CalendarEvent>>('calendar', started);
      final ProviderContainer container =
          ProviderContainer(overrides: <Override>[
        badgeControllerProvider.overrideWith(() => _BadgeController(badge)),
        groupControllerProvider.overrideWith(() => _GroupController(group)),
        tagControllerProvider.overrideWith(() => _TagController(tag)),
        venueControllerProvider.overrideWith(() => _VenueController(venue)),
        userControllerProvider.overrideWith(() => _UserController(user)),
        eventControllerProvider.overrideWith(() => _EventController(event)),
        userEventControllerProvider
            .overrideWith(() => _UserEventController(userEvent)),
        participationControllerProvider
            .overrideWith(() => _ParticipationController(participation)),
        calendarEventsProvider
            .overrideWith(() => _CalendarEventController(calendar)),
      ]);
      addTearDown(container.dispose);
      final Future<void> loading = loadInitialData(container);
      final Future<void>? expectedFailure = failReferenceData
          ? expectLater(loading, throwsA(isA<StateError>()))
          : null;
      expect(started, <String>['badge', 'group', 'tag', 'venue']);
      badge.completer.complete(<LincaBadge>[]);
      group.completer.complete(<Group>[]);
      tag.completer.complete(<Tag>[]);
      await Future<void>.delayed(Duration.zero);
      expect(started, <String>['badge', 'group', 'tag', 'venue']);

      if (failReferenceData) {
        venue.completer.completeError(StateError('reference load failed'));
        await expectedFailure;
        expect(started, <String>['badge', 'group', 'tag', 'venue']);
        return;
      }
      venue.completer.complete(<Venue>[]);
      await Future<void>.delayed(Duration.zero);
      expect(started.last, 'user');
      expect(started, hasLength(5));

      user.completer.complete(const LincaUser());
      await Future<void>.delayed(Duration.zero);
      expect(started.skip(5), <String>['event', 'userEvent', 'participation']);
      event.completer.complete(<LincaEvent>[]);
      userEvent.completer.complete(<LincaEvent>[]);
      await Future<void>.delayed(Duration.zero);
      expect(started, hasLength(8));

      participation.completer.complete(<ParticipationInfo>[]);
      await Future<void>.delayed(Duration.zero);
      expect(started.last, 'calendar');
      calendar.completer.complete(<CalendarEvent>[]);
      await loading;
      // Re-reading initialized providers must not trigger additional loads.
      await loadInitialData(container);
      expect(started, hasLength(9));
    });
  }
}
