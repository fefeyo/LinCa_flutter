import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';

class RequiredRichText extends StatelessWidget {
  const RequiredRichText({
    super.key,
    required this.isFocused,
    required this.text,
  });

  final bool isFocused;
  final String text;

  @override
  Widget build(BuildContext context) => RichText(
        text: TextSpan(
          text: text,
          style: context.textTheme.bodyLarge?.copyWith(
            color: isFocused
                ? context.theme.colorScheme.primary
                : context.theme.hintColor,
          ),
          children: <TextSpan>[
            TextSpan(
              text: ' ${context.l10n.common_required}',
              style: context.textTheme.bodyLarge?.copyWith(
                color: Colors.red,
              ),
            ),
          ],
        ),
      );
}
