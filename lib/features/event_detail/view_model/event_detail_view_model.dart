import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import '../../../core/models/check_in_condition.dart';
import '../data/event_detail_state.dart';

final StateNotifierProvider<EventDetailViewModel, EventDetailState>
    eventDetailViewModelProvider =
    StateNotifierProvider<EventDetailViewModel, EventDetailState>(
        (Ref ref) => EventDetailViewModel());

class EventDetailViewModel extends StateNotifier<EventDetailState> {
  EventDetailViewModel() : super(const EventDetailState(isLoading: false));

  Future<void> checkLocation(LincaEvent lincaEvent) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        checkInCondition: CheckInCondition.locationPermissionDisabled,
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        state = state.copyWith(
          checkInCondition: CheckInCondition.locationPermissionDenied,
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(
        checkInCondition: CheckInCondition.locationPermissionDeniedForever,
      );
      return;
    }

    // デバッグ用座標
    // const double latitude = 35.70257256443094;
    // const double longitude = 139.9614243929062;
    final Position currentPosition = await Geolocator.getCurrentPosition();
    final double distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      lincaEvent.venue.latitude,
      lincaEvent.venue.longitude,
    );
    if (distance <= AppConstants.checkInRadius) {
      state = state.copyWith(
        checkInCondition: CheckInCondition.inRange,
      );
    } else {
      state = state.copyWith(
        checkInCondition: CheckInCondition.outRange,
      );
    }
  }

  void resetCheckInState() => state = state.copyWith(
        checkInCondition: null,
        isLoading: false,
      );
}
