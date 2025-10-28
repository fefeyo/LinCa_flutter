import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../../env/env.dart';
import '../model/venue.dart';
import '../providers.dart';
import '../repository/venue_repository.dart';

class VenueController extends AsyncNotifier<List<Venue>> {
  late VenueRepository venueRepository;

  @override
  FutureOr<List<Venue>> build() async {
    venueRepository = ref.read(venueRepositoryProvider);
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    List<Venue> venues = await venueRepository.getVenues();
    if (preferences.getString(AppConstants.venueVersionKey) !=
            packageInfo.version ||
        venues.isEmpty ||
        Env.flavor != 'prod') {
      venues = await venueRepository.fetchVenues();
      await preferences.setString(
          AppConstants.venueVersionKey, packageInfo.version);
    }

    return venues;
  }
}
