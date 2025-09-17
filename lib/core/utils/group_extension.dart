import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linca_otaku_support/core/network/model/group.dart';

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
}
