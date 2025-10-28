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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onClick,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 16,),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: participationType == selectedParticipationType
                    ? context.colorScheme.primary.withValues(alpha: 0.25)
                    : Colors.transparent,
              ),
              child: Icon(
                iconData,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 50,
              child: Text(
                participationType.label(context),
                style: context.textTheme.bodyMedium,
                softWrap: true,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}
