import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:linca_otaku_support/core/network/model/group.dart';
import 'package:linca_otaku_support/core/utils/color_extension.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';

import '../asset_gen/assets.gen.dart';

extension GroupExtension on Group {
  Widget getLogoWidget() {
    switch (seriesTag) {
      case AppConstants.seriesTagLovelive:
        return Image.asset(
          Assets.images.lovelive.path,
          height: 32,
          fit: BoxFit.contain,
        );
      case AppConstants.seriesTagSunshine:
        return Image.asset(
          Assets.images.sunshine.path,
          height: 32,
          fit: BoxFit.contain,
        );
      case AppConstants.seriesTagNijigasaki:
        return Image.asset(
          Assets.images.nijigasaki.path,
          height: 32,
          fit: BoxFit.contain,
        );
      case AppConstants.seriesTagSuperstar:
        return Image.asset(
          Assets.images.superstar.path,
          height: 32,
          fit: BoxFit.contain,
        );
      case AppConstants.seriesTagHasunosora:
        return SvgPicture.asset(
          Assets.images.hasunosora.path,
          height: 32,
          fit: BoxFit.contain,
        );
      case AppConstants.seriesTagIkizulive:
        return Image.asset(
          Assets.images.ikizulive.path,
          height: 32,
          fit: BoxFit.contain,
        );
      case AppConstants.seriesTagCollaborative:
        return SvgPicture.asset(
          Assets.images.loveliveSeries.path,
          height: 32,
          fit: BoxFit.contain,
        );
      case AppConstants.seriesTagMusical:
        return Image.asset(
          Assets.images.musical.path,
          height: 32,
          fit: BoxFit.contain,
        );
      case AppConstants.seriesTagYohane:
        return Image.asset(
          Assets.images.yohane.path,
          height: 32,
          fit: BoxFit.contain,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Color getSeriesColor(BuildContext context) {
    if (seriesTag.isEmpty) return Colors.grey;
    switch (seriesTag) {
      case AppConstants.seriesTagLovelive:
        return context.colorScheme.colorLovelive;
      case AppConstants.seriesTagSunshine:
        return context.colorScheme.colorSunshine;
      case AppConstants.seriesTagNijigasaki:
        return context.colorScheme.colorNijigasaki;
      case AppConstants.seriesTagSuperstar:
        return context.colorScheme.colorSuperstar;
      case AppConstants.seriesTagHasunosora:
        return context.colorScheme.colorHasunosora;
      case AppConstants.seriesTagIkizulive:
        return context.colorScheme.colorIkizulive;
      case AppConstants.seriesTagMusical:
        return context.colorScheme.colorMusical;
      case AppConstants.seriesTagYohane:
        return context.colorScheme.colorYohane;
      default:
        return context.colorScheme.colorLovelive;
    }
  }

  LinearGradient getSeriesGradientForGraph(BuildContext context) {
    switch (seriesTag) {
      case AppConstants.seriesTagLovelive:
        return context.colorScheme.gradientMuseForGraph;
      case AppConstants.seriesTagSunshine:
        return context.colorScheme.gradientAqoursForGraph;
      case AppConstants.seriesTagNijigasaki:
        return context.colorScheme.gradientNijigasakiForGraph;
      case AppConstants.seriesTagSuperstar:
        return context.colorScheme.gradientLiellaForGraph;
      case AppConstants.seriesTagHasunosora:
        return context.colorScheme.gradientHasunosoraForGraph;
      case AppConstants.seriesTagIkizulive:
        return context.colorScheme.gradientIkizuliveForGraph;
      default:
        return context.colorScheme.gradientMuseForGraph;
    }
  }
}

extension GroupsExtension on List<Group> {
  Color getFavoriteColor(BuildContext context) =>
      isNotEmpty ? colorFromHex(first.color) : context.colorScheme.primary;
}
