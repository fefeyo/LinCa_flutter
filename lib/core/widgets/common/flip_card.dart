import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    final TickerProvider vsync = useSingleTickerProvider();
    final AnimationController controller = useAnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );

    // final ValueNotifier<bool> isFrontNotifier = useState(isFront);

    // flipアニメーション
    useEffect(() {
      if (isFront) {
        controller.reverse();
      } else {
        controller.forward();
      }
      // isFrontNotifier.value = isFront;
      return null;
    }, <Object?>[isFront]);

    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        final double angle = controller.value * pi;
        final bool isBackVisible = controller.value >= 0.5;

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
