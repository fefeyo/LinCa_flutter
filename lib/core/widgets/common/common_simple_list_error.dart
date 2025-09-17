import '../../../core/utils/context_extension.dart';
import 'package:flutter/material.dart';

class CommonSimpleListError extends StatelessWidget {
  const CommonSimpleListError({
    super.key,
    required this.error,
    required this.retry,
  });

  final Object error;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          children: <Widget>[
            Text(
              'エラーが発生しました\n$error',
              style: context.textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: retry,
              child: const Text('再読み込み'),
            ),
          ],
        ),
      );
}
