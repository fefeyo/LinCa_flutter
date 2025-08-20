import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data/my_page_state.dart';
import 'view_model/my_page_view_model.dart';

@RoutePage()
class MyPage extends HookConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MyPageState state = ref.watch(myPageViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('my_page')),
      body: Center(
        child: Text(state.name),
      ),
    );
  }
}
