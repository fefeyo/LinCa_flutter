import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/widgets/common/linca_interaction.dart';

class FlipCard extends HookConsumerWidget {
  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    required this.isFront,
  });

  final Widget front;
  final Widget back;
  final bool isFront;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool reducedMotion = MediaQuery.disableAnimationsOf(context);
    final TickerProvider vsync = useSingleTickerProvider();
    final AnimationController controller = useAnimationController(
      vsync: vsync,
      duration: lincaMotionDuration(context, const Duration(milliseconds: 440)),
      initialValue: isFront ? 0 : 1,
    );

    useEffect(() {
      if (reducedMotion) {
        controller.value = isFront ? 0 : 1;
      } else if (isFront) {
        controller.reverse();
      } else {
        controller.forward();
      }
      return null;
    }, <Object?>[isFront, reducedMotion]);

    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        final double progress =
            Curves.easeInOutCubic.transform(controller.value);
        final double angle = progress * pi;
        final bool isBackVisible = progress >= 0.5;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: isBackVisible
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi),
                  child: back,
                )
              : front,
        );
      },
    );
  }
}
