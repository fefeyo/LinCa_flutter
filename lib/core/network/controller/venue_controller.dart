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
      venueRepository.refreshInBackground(
          current: state.value ?? <Venue>[],
          onChanged: (List<Venue> venues) {
            state = AsyncValue<List<Venue>>.data(venues);
          });
    } else {
      venues.addAll(await venueRepository.fetch());
    }

    return venues;
  }
}
