import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data/login_state.dart';
import 'view_model/login_view_model.dart';

@RoutePage()
class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LoginState state = ref.watch(loginViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('login')),
      body: Center(
        child: Text(state.name),
      ),
    );
  }
}
