import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/utils/participation_type_extension.dart';

import '../../../core/constants/participation_type.dart';
import '../../../core/utils/context_extension.dart';

class CustomParticipationButton extends StatelessWidget {
  const CustomParticipationButton({
    super.key,
    required this.participationType,
    required this.selectedParticipationType,
    required this.iconData,
    required this.onClick,
  });

  final ParticipationType participationType;
  final ParticipationType selectedParticipationType;
  final IconData iconData;
  final VoidCallback onClick;

  bool get isSelected => participationType == selectedParticipationType;

  @override
  Widget build(BuildContext context) {
    final Color primary = context.colorScheme.primary;

    return AnimatedContainer(
      height: 100,
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.zero, // ← 親に任せる
      decoration: BoxDecoration(
        color: isSelected ? primary : Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        boxShadow: isSelected
            ? <BoxShadow>[
                BoxShadow(
                  color: primary.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onClick,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              iconData,
              size: 30,
              color: isSelected
                  ? context.colorScheme.onPrimary
                  : context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            Text(
              participationType.label(context),
              textAlign: TextAlign.center,
              style: context.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? context.colorScheme.onPrimary
                    : context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
