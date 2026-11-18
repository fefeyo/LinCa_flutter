import 'dart:async';

import 'package:linca_otaku_support/core/network/controller/linca_controller.dart';
import '../model/venue.dart';
import '../providers.dart';
import '../repository/venue_repository.dart';

class VenueController extends LincaController<List<Venue>> {
  late VenueRepository venueRepository;

  @override
  FutureOr<List<Venue>> buildImpl() async {
    venueRepository = ref.read(venueRepositoryProvider);
    return venueRepository.getLatest(
      getId: (Venue venue) => venue.id,
    );
  }
}
