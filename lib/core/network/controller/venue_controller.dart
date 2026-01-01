import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/network/controller/linca_controller.dart';
import '../model/venue.dart';
import '../providers.dart';
import '../repository/venue_repository.dart';

class VenueController extends LincaController<List<Venue>> {
  late VenueRepository venueRepository;

  @override
  FutureOr<List<Venue>> buildImpl() async {
    venueRepository = ref.read(venueRepositoryProvider);
    final List<Venue> venues = await venueRepository.get();

    if (venues.isNotEmpty) {
      unawaited(_refreshInBackground(venues));
    } else {
      venues.addAll(await venueRepository.fetch());
    }

    return venues;
  }

  Future<void> _refreshInBackground(List<Venue> current) async {
    final List<Venue> updated = await venueRepository.fetch();

    venueRepository.refreshInBackground(
      current: current,
      updated: updated,
      getId: (Venue venue) => venue.id,
      onChanged: (List<Venue> venues) {
        state = AsyncValue<List<Venue>>.data(venues);
      },
    );
  }
}
