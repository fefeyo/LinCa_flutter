import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/widgets/common/linca_interaction.dart';
import 'package:linca_otaku_support/core/utils/color_extension.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/date_extension.dart';

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
    Color? background;
    Color textColor = date.isWeekEnd || isHoliday
        ? context.colorScheme.error
        : context.colorScheme.onSurface;
    final Color dotColor =
        hasEvent ? context.colorScheme.colorLovelive : Colors.blue;
    final bool showDot = hasEvent || hasAnniversary;
    final bool disableAnimations = MediaQuery.disableAnimationsOf(context);
    final Duration duration =
        disableAnimations ? Duration.zero : const Duration(milliseconds: 220);

    if (isSelected) {
      background = context.colorScheme.primary;
      textColor = Colors.white;
    } else if (isToday) {
      background = context.colorScheme.primary.withValues(alpha: 0.15);
    }

    return Semantics(
      selected: isSelected,
      button: true,
      child: LincaInteractive(
        builder: (BuildContext context, WidgetStatesController states) =>
            InkWell(
          statesController: states,
          borderRadius: BorderRadius.circular(isSelected ? 14 : 10),
          onTap: onTap,
          child: AnimatedScale(
            scale: isSelected && !disableAnimations ? 1.08 : 1,
            duration: duration,
            curve: isSelected ? Curves.easeOutBack : Curves.easeOutCubic,
            child: Stack(
              children: <Widget>[
                AnimatedContainer(
                  duration: duration,
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(isSelected ? 14 : 10),
                    boxShadow: isSelected
                        ? <BoxShadow>[
                            BoxShadow(
                              color: context.colorScheme.primary.withValues(
                                alpha: 0.24,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : const <BoxShadow>[],
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: duration,
                    curve: Curves.easeOutCubic,
                    style: context.textTheme.bodyMedium?.copyWith(
                          color: textColor,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ) ??
                        TextStyle(color: textColor),
                    child: Text('${date.day}'),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  left: 0,
                  right: 0,
                  child: AnimatedScale(
                    scale: showDot ? 1 : 0,
                    duration: duration,
                    curve: showDot ? Curves.easeOutBack : Curves.easeInCubic,
                    child: AnimatedOpacity(
                      opacity: showDot ? 1 : 0,
                      duration: duration,
                      child: Center(
                        child: AnimatedContainer(
                          width: isSelected ? 6 : 5,
                          height: isSelected ? 6 : 5,
                          duration: duration,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
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
