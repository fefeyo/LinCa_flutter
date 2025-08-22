import 'package:fefeyo_flutter_template/core/utils/context_extension.dart';
import 'package:flutter/material.dart';

class MyPageItem extends StatelessWidget {
  const MyPageItem({
    super.key,
    required this.title,
    required this.onClickItem,
  });

  final String title;
  final VoidCallback onClickItem;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: context.colorScheme.surfaceContainer,
      title: Text(
        title,
        style: context.textTheme.titleMedium,
      ),
      trailing: const Icon(Icons.arrow_right),
      onTap: onClickItem,
    );
  }
}
