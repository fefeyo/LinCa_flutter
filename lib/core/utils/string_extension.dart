import '../../core/constants/app_constants.dart';

String buildLinCaUri(String userId) => '${AppConstants.lincaScheme}$userId';

extension StringExtension on String {
  String buildLinCaUri() => '${AppConstants.lincaScheme}$this';
  String get userId {
    final RegExp regExp = RegExp(r'linca://card/(.+)');
    final Match? match = regExp.firstMatch(this);

    return match?.group(1) ?? '';
  }
}
