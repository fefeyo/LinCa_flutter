import '../../../core/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/widgets/common/pressable_scale.dart';

class MyPageItem extends StatelessWidget {
  const MyPageItem({
    super.key,
    required this.title,
    required this.onClickItem,
    this.subtitle,
    this.trailing = const Icon(Icons.arrow_right),
  });

  final String title;
  final VoidCallback onClickItem;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      pressedScale: 0.985,
      child: ListTile(
        tileColor: context.colorScheme.surfaceContainer,
        title: Text(title, style: context.textTheme.bodyMedium),
        subtitle: subtitle != null
            ? Text(subtitle!, style: context.textTheme.bodySmall)
            : null,
        trailing: trailing,
        onTap: onClickItem,
      ),
    );
  }
}
