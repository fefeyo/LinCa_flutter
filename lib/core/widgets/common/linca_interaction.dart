import 'package:flutter/material.dart';

const Duration lincaQuickMotion = Duration(milliseconds: 120);
const Duration lincaSelectionMotion = Duration(milliseconds: 240);

Duration lincaMotionDuration(
  BuildContext context, [
  Duration duration = lincaSelectionMotion,
]) =>
    MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;

/// Uses the control's own states, keeping its gestures, focus, semantics and
/// callbacks intact. In particular, a scroll cancels the underlying InkWell.
class LincaInteractive extends StatefulWidget {
  const LincaInteractive({super.key, required this.builder});

  final Widget Function(BuildContext context, WidgetStatesController states)
      builder;

  @override
  State<LincaInteractive> createState() => _LincaInteractiveState();
}

class _LincaInteractiveState extends State<LincaInteractive> {
  final WidgetStatesController _states = WidgetStatesController();

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<WidgetState>>(
      valueListenable: _states,
      child: widget.builder(context, _states),
      builder: (BuildContext context, Set<WidgetState> states, Widget? child) {
        return _interactionScale(context, states, child, pressedScale: 0.98);
      },
    );
  }
}

/// Shared by Material buttons through their theme, including keyboard presses.
Widget lincaButtonForeground(
  BuildContext context,
  Set<WidgetState> states,
  Widget? child,
) =>
    _interactionScale(context, states, child, pressedScale: 0.94);

Widget _interactionScale(
  BuildContext context,
  Set<WidgetState> states,
  Widget? child, {
  required double pressedScale,
}) {
  final bool enabled = !states.contains(WidgetState.disabled);
  final bool pressed = enabled && states.contains(WidgetState.pressed);
  final bool hovered = enabled && states.contains(WidgetState.hovered);
  return AnimatedScale(
    scale: MediaQuery.disableAnimationsOf(context)
        ? 1
        : pressed
            ? pressedScale
            : hovered
                ? 1.01
                : 1,
    duration: lincaMotionDuration(
      context,
      pressed ? lincaQuickMotion : lincaSelectionMotion,
    ),
    curve: pressed ? Curves.easeOutCubic : Curves.easeOutBack,
    child: child,
  );
}

/// For small, read-only labels. Keep forms and routed pages outside switchers.
class LincaAnimatedLabel extends StatelessWidget {
  const LincaAnimatedLabel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: lincaMotionDuration(context),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: child,
    );
  }
}

class LincaNavigationIcon extends StatelessWidget {
  const LincaNavigationIcon({
    super.key,
    required this.icon,
    required this.selected,
  });

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: lincaMotionDuration(context),
      curve: Curves.easeOutCubic,
      width: 48,
      height: 32,
      decoration: BoxDecoration(
        color: selected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: AnimatedScale(
          scale: selected && !MediaQuery.disableAnimationsOf(context) ? 1.1 : 1,
          duration: lincaMotionDuration(context),
          curve: Curves.easeOutBack,
          child: Icon(icon),
        ),
      ),
    );
  }
}

class LincaSuccessIcon extends StatelessWidget {
  const LincaSuccessIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final bool reduced = MediaQuery.disableAnimationsOf(context);
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: reduced ? 1 : 0.6, end: 1),
        duration: lincaMotionDuration(context),
        curve: Curves.easeOutBack,
        builder: (BuildContext context, double scale, Widget? child) =>
            Transform.scale(scale: reduced ? 1 : scale, child: child),
        child: const Icon(Icons.check_circle_rounded, color: Colors.white),
      ),
    );
  }
}
