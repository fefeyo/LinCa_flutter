import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/user_profile.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/features/linca_detail/data/linca_detail_state.dart';
import 'package:linca_otaku_support/features/linca_detail/view_model/linca_detail_view_model.dart';

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
    final LincaDetailState state = ref.watch(lincaDetailViewModelProvider);
    final LincaDetailViewModel viewModel =
        ref.read(lincaDetailViewModelProvider.notifier);

    useEffect(() {
      Future<void>.microtask(() {
        viewModel.setUpcomingEvent(userProfile.user.id);
      });

      return null;
    }, const <Object?>[]);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Stack(
            children: <Widget>[
              FlipCard(
                front: LincaVertical(
                  userProfile: userProfile,
                  upcomingEvent: state.upcomingEvent,
                  tintColor: context.colorScheme.primary,
                  isFullScreen: true,
                  animationTag: animationTag,
                ),
                back: LincaVerticalBack(
                  animationTag: animationTag,
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black26,
                    shape: const CircleBorder(),
                    fixedSize: const Size(48, 48),
                    padding: EdgeInsets.zero,
                  ),
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
