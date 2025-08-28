import 'package:freezed_annotation/freezed_annotation.dart';

part 'venue.freezed.dart';

part 'venue.g.dart';

@freezed
abstract class Venue with _$Venue {
  const factory Venue({
    @Default('') String id,
    @Default('') String name,
    @Default('') String slug,
    @Default('') String category,
    @Default(false) bool active,
    @Default(0) int order,
  }) = _Venue;

  factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);
}
