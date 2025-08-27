import 'package:fefeyo_flutter_template/core/utils/context_extension.dart';
import 'package:flutter/material.dart';

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
    return ListTile(
      tileColor: context.colorScheme.surfaceContainer,
      title: Text(
        title,
        style: context.textTheme.titleMedium,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: context.textTheme.bodyMedium,
            )
          : null,
      trailing: trailing,
      onTap: onClickItem,
    );
  }
}
