import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/user_profile.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';

import '../../core/widgets/common/flip_card.dart';
import '../my_page/view/linca_vertical.dart';
import '../my_page/view/linca_vertical_back.dart';

@RoutePage()
class LincaDetailPage extends HookConsumerWidget {
  const LincaDetailPage({
    super.key,
    required this.userProfile,
    this.animationTag = '',
  });

  final UserProfile userProfile;
  final String animationTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Stack(
            children: <Widget>[
              FlipCard(
                front: LincaVertical(
                  userProfile: userProfile,
                  tintColor: context.colorScheme.primary,
                  isFullScreen: true,
                  animationTag: animationTag,
                ),
                back: LincaVerticalBack(
                  animationTag: animationTag,
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
