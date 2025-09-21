import 'dart:ui';

Color colorFromHex(String hexColor) {
  final String cleanedHex = hexColor.replaceFirst('#', '');
  final String fullHex = cleanedHex.length == 6 ? 'FF$cleanedHex' : cleanedHex;

  return Color(int.parse(fullHex, radix: 16));
}
