import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data/qr_code_read_state.dart';
import 'view_model/qr_code_read_view_model.dart';

@RoutePage()
class QrCodeReadPage extends HookConsumerWidget {
  const QrCodeReadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QrCodeReadState state = ref.watch(qrCodeReadViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('qr_code_read')),
      body: Center(
        child: Text(state.name),
      ),
    );
  }
}
