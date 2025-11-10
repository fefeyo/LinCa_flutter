import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/linca_user.dart';
import 'package:linca_otaku_support/features/linca_detail/data/linca_detail_state.dart';
import 'package:linca_otaku_support/features/linca_detail/view_model/linca_detail_view_model.dart';

import '../../core/widgets/common/flip_card.dart';
import '../my_page/view/linca_vertical.dart';
import '../my_page/view/linca_vertical_back.dart';

@RoutePage()
class LincaDetailPage extends HookConsumerWidget {
  const LincaDetailPage({
    super.key,
    required this.lincaUser,
    this.animationTag = '',
  });

  final LincaUser lincaUser;
  final String animationTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    final LincaDetailState state = ref.watch(lincaDetailViewModelProvider);
    final LincaDetailViewModel viewModel =
        ref.read(lincaDetailViewModelProvider.notifier);
    final ValueNotifier<bool> isFront = useState(true);

    useEffect(() {
      Future<void>.microtask(() {
        viewModel.setUpcomingEvent(lincaUser.user.id);
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
                  lincaUser: lincaUser,
                  upcomingEvent: state.upcomingEvent,
                  isFullScreen: true,
                  animationTag: animationTag,
                  onClickFlip: () => isFront.value = !isFront.value,
                  onClickClose: () {
                    SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.edgeToEdge);
                    context.router.pop();
                  },
                ),
                back: LincaVerticalBack(
                  participationEvents: state.participationEvents,
                  animationTag: animationTag,
                  onClickFlip: () => isFront.value = !isFront.value,
                  onClickClose: () {
                    SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.edgeToEdge);
                    context.router.pop();
                  },
                ),
                isFront: isFront.value,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
