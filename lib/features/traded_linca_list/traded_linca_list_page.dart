import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data/traded_linca_list_state.dart';
import 'view_model/traded_linca_list_view_model.dart';

@RoutePage()
class TradedLincaListPage extends HookConsumerWidget {
  const TradedLincaListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TradedLincaListState state =
        ref.watch(tradedLincaListViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('traded_linca_list')),
      body: Center(
        child: Text(state.name),
      ),
    );
  }
}
