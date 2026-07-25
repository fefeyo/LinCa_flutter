import 'package:flutter/material.dart';

/// Adds a subtle, reusable press response without taking over the child's tap.
///
/// The child keeps ownership of gestures and semantics, so this can wrap
/// buttons, cards, and list tiles without changing their behavior.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.pressedScale = 0.97,
    this.duration = const Duration(milliseconds: 140),
    this.alignment = Alignment.center,
  });

  final Widget child;
  final double pressedScale;
  final Duration duration;
  final Alignment alignment;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value || !mounted) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final bool disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        alignment: widget.alignment,
        scale: _isPressed && !disableAnimations ? widget.pressedScale : 1,
        duration: disableAnimations ? Duration.zero : widget.duration,
        curve: _isPressed ? Curves.easeOutCubic : Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}
