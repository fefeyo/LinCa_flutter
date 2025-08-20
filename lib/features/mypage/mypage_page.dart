import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data/mypage_state.dart';
import 'view_model/mypage_view_model.dart';

@RoutePage()
class MypagePage extends HookConsumerWidget {
  const MypagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MypageState state = ref.watch(mypageViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('mypage')),
      body: Center(
        child: Text(state.name),
      ),
    );
  }
}
