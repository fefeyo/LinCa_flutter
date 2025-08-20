import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data/linca_detail_state.dart';
import 'view_model/linca_detail_view_model.dart';

@RoutePage()
class LincaDetailPage extends HookConsumerWidget {
  const LincaDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LincaDetailState state = ref.watch(lincaDetailViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('linca_detail')),
      body: Center(
        child: Text(state.name),
      ),
    );
  }
}
