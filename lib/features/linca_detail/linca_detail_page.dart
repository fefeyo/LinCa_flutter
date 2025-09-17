import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/utils/sort_items_extension.dart';
import '../../core/widgets/common/flip_card.dart';
import '../my_page/view/linca_vertical.dart';
import '../my_page/view/linca_vertical_back.dart';

@RoutePage()
class LincaDetailPage extends HookConsumerWidget {
  const LincaDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Stack(
            children: <Widget>[
              const FlipCard(
                front: Hero(
                  tag: 'LinCaCard',
                  child: LincaVertical(
                    name: 'ふぇふぇ',
                    avatar: AssetImage('assets/images/user.png'),
                    seriesChips: <SeriesTag>[
                      SeriesTag.muse,
                      SeriesTag.aqours,
                      SeriesTag.nijigasaki,
                      SeriesTag.liella,
                      SeriesTag.hasunosora,
                      SeriesTag.ikizulive,
                      SeriesTag.collaborative,
                    ],
                    bio:
                        '''現地参戦メイン。物販列情報はXで共有します！現地参戦メイン。物販列情報はXで共有します！現地参戦メイン。物販列情報はXで共有します！現地参戦メイン。物販列情報はXで共有します！現地参戦メイン。物販列情報はXで共有します！
                ''',
                    tintColor: Colors.purple,
                    isFullScreen: true,
                  ),
                ),
                back: Hero(
                  tag: 'LinCaCard',
                  child: LincaVerticalBack(),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.edgeToEdge);
                    context.router.pop();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
