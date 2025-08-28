import 'dart:async';

import 'package:fefeyo_flutter_template/core/network/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../model/venue.dart';
import '../repository/venue_repository.dart';

class VenueController extends AsyncNotifier<List<Venue>> {
  late VenueRepository venueRepository;

  @override
  FutureOr<List<Venue>> build() async {
    venueRepository = ref.read(venueRepositoryProvider);
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    List<Venue> venues = await getVenues();
    if (preferences.getString(AppConstants.venueVersionKey) !=
            packageInfo.version ||
        venues.isEmpty) {
      venues = await fetchVenues();
      await preferences.setString(
          AppConstants.venueVersionKey, packageInfo.version);
    }

    return venues;
  }

  Future<List<Venue>> getVenues() => venueRepository.getVenues();

  Future<List<Venue>> fetchVenues() => venueRepository.fetchVenues();
}
