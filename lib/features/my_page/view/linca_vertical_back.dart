import 'package:flutter/material.dart';
import '../../../core/utils/context_extension.dart';

class LincaVerticalBack extends StatelessWidget {
  const LincaVerticalBack({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = context.theme.brightness == Brightness.light
        ? context.colorScheme.surface
        : context.colorScheme.surfaceContainer;

    return Material(
      color: Colors.transparent,
      child: SizedBox.expand(
        child: _buildCard(context, backgroundColor),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    Color backgroundColor,
  ) =>
      Card(
        color: backgroundColor,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            Text(
              '裏面です',
              style: context.textTheme.headlineMedium,
            ),
          ],
        ),
      );
}
