import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linca_otaku_support/core/network/model/group.dart';
import 'package:linca_otaku_support/core/utils/color_extension.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';

import '../asset_gen/assets.gen.dart';

extension GroupExtension on Group {
  Widget getLogoWidget() {
    switch (slug) {
      case 'muse':
        return SvgPicture.asset(
          Assets.images.muse.path,
          height: 32,
          fit: BoxFit.contain,
        );
      case 'aqours':
        return SvgPicture.asset(
          Assets.images.aqours.path,
          height: 32,
          fit: BoxFit.contain,
        );
      case 'nijigasaki':
        return SvgPicture.asset(
          Assets.images.nijigasaki.path,
          height: 32,
          fit: BoxFit.contain,
        );
      case 'liella':
        return SvgPicture.asset(
          Assets.images.liella.path,
          height: 32,
          fit: BoxFit.contain,
        );
      case 'hasunosora':
        return SvgPicture.asset(
          Assets.images.hasunosora.path,
          height: 32,
          fit: BoxFit.contain,
        );
      case 'ikizulive':
        return Image.asset(
          Assets.images.ikizulive.path,
          height: 32,
          fit: BoxFit.contain,
        );
      case 'collaborative':
        return SvgPicture.asset(
          Assets.images.loveliveSeries.path,
          height: 32,
          fit: BoxFit.contain,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Color getSeriesColor(BuildContext context) {
    switch (slug) {
      case 'muse':
        return context.colorScheme.colorMuse;
      case 'aqours':
        return context.colorScheme.colorAqours;
      case 'nijigasaki':
        return context.colorScheme.colorNijigasaki;
      case 'liella':
        return context.colorScheme.colorLiella;
      case 'hasunosora':
        return context.colorScheme.colorHasunosora;
      case 'ikizulive':
        return context.colorScheme.colorIkizulive;
      default:
        return context.colorScheme.colorMuse;
    }
  }

  LinearGradient getSeriesGradient({
    required BuildContext context,
    required Alignment begin,
    required Alignment end,
  }) {
    switch (slug) {
      case 'muse':
        return context.colorScheme.gradientMuse(
          begin: begin,
          end: end,
        );
      case 'aqours':
        return context.colorScheme.gradientAqours(
          begin: begin,
          end: end,
        );
      case 'nijigasaki':
        return context.colorScheme.gradientNijigasaki(
          begin: begin,
          end: end,
        );
      case 'liella':
        return context.colorScheme.gradientLiella(
          begin: begin,
          end: end,
        );
      case 'hasunosora':
        return context.colorScheme.gradientHasunosora(
          begin: begin,
          end: end,
        );
      case 'ikizulive':
        return context.colorScheme.gradientIkizulive(
          begin: begin,
          end: end,
        );
      default:
        return context.colorScheme.gradientMuse(
          begin: begin,
          end: end,
        );
    }
  }

  LinearGradient getSeriesGradientForGraph(BuildContext context) {
    switch (slug) {
      case 'muse':
        return context.colorScheme.gradientMuseForGraph;
      case 'aqours':
        return context.colorScheme.gradientAqoursForGraph;
      case 'nijigasaki':
        return context.colorScheme.gradientNijigasakiForGraph;
      case 'liella':
        return context.colorScheme.gradientLiellaForGraph;
      case 'hasunosora':
        return context.colorScheme.gradientHasunosoraForGraph;
      case 'ikizulive':
        return context.colorScheme.gradientIkizuliveForGraph;
      default:
        return context.colorScheme.gradientMuseForGraph;
    }
  }
}
