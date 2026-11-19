import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/widgets/common/linca_interaction.dart';

class LincaCalendarDayCell extends StatelessWidget {
  const LincaCalendarDayCell({
    super.key,
    required this.date,
    required this.isToday,
    required this.isHoliday,
    required this.isSelected,
    required this.hasEvent,
    required this.hasAnniversary,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isHoliday;
  final bool isSelected;
  final bool hasEvent;
  final bool hasAnniversary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool dark = scheme.brightness == Brightness.dark;
    final bool reduced = MediaQuery.disableAnimationsOf(context);
    final Duration duration = lincaMotionDuration(context);
    final Color ink = isSelected
        ? const Color(0xFF183C50)
        : isHoliday || date.weekday == DateTime.sunday
            ? (dark ? const Color(0xFFFFA6C5) : const Color(0xFFB5416C))
            : date.weekday == DateTime.saturday
                ? (dark ? const Color(0xFF86D7FF) : const Color(0xFF086DA8))
                : scheme.onSurface;

    return Semantics(
      selected: isSelected,
      button: true,
      child: LincaInteractive(
        builder: (BuildContext context, WidgetStatesController states) =>
            InkWell(
          statesController: states,
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedScale(
            scale: isSelected && !reduced ? 1.04 : 1,
            duration: duration,
            curve: Curves.easeOutBack,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned.fill(
                  child: AnimatedRotation(
                    turns: isSelected && !reduced ? -0.012 : 0,
                    duration: duration,
                    curve: Curves.easeOutBack,
                    child: AnimatedContainer(
                      duration: duration,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF91E6F8) : null,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? const Color(0xFF4CC3FF)
                                  : Colors.transparent,
                          width: isSelected ? 3 : 2,
                        ),
                        boxShadow: isSelected
                            ? <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.14),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : const <BoxShadow>[],
                      ),
                    ),
                  ),
                ),
                if (isSelected)
                  const Positioned(
                    top: 6,
                    left: 7,
                    child: ExcludeSemantics(
                      child: SizedBox(
                        width: 8,
                        height: 3,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${date.day}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ink,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  child: ExcludeSemantics(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (hasEvent)
                          const Icon(Icons.circle,
                              size: 7, color: Color(0xFFE84586)),
                        if (hasEvent && hasAnniversary)
                          const SizedBox(width: 3),
                        if (hasAnniversary)
                          const Icon(Icons.star_rounded,
                              size: 11, color: Color(0xFF9860CB)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
