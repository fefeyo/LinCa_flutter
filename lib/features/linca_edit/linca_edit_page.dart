import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data/linca_edit_state.dart';
import 'view_model/linca_edit_view_model.dart';

@RoutePage()
class LincaEditPage extends HookConsumerWidget {
  const LincaEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LincaEditState state = ref.watch(lincaEditViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('linca_edit')),
      body: Center(
        child: Text(state.name),
      ),
    );
  }
}
