import 'package:freezed_annotation/freezed_annotation.dart';

class LocalDateConverter
    implements JsonConverter<DateTime, Object> {
  const LocalDateConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is String) {
      // ISO 8601 (2024-12-31T15:00:00.000Z) 対応
      if (json.contains('T')) {
        final DateTime dt = DateTime.parse(json).toLocal();
        return DateTime(dt.year, dt.month, dt.day);
      }

      // yyyy-MM-dd
      final List<String> parts = json.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }

    throw UnsupportedError('Unsupported date format: $json');
  }

  @override
  Object toJson(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
}
