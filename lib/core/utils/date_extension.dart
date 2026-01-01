import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

extension DateTimeExtention on DateTime {
  String simpleDateFormat() => DateFormat('yyyy/MM/dd(E)', 'ja_JP').format(this);

  bool get isToday {
    final DateTime now = DateTime.now();
    return year == now.year &&
        month == now.month &&
        day == now.day;
  }

  bool isSameDate(DateTime other) {
    return year == other.year &&
        month == other.month &&
        day == other.day;
  }
}

/// Firestore Timestamp + ISO8601文字列 両対応
DateTime? fromJsonDate(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value);
  throw ArgumentError('Invalid date format: $value');
}

dynamic toJsonDate(DateTime? date) {
  return date?.toIso8601String();
}
