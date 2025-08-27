import 'package:fefeyo_flutter_template/core/auth/controller/auth_controller.dart';
import 'package:fefeyo_flutter_template/core/auth/providers.dart';
import 'package:fefeyo_flutter_template/core/router/app_router.gr.dart';
import 'package:fefeyo_flutter_template/core/utils/context_extension.dart';
import 'package:fefeyo_flutter_template/features/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sign_in_button/sign_in_button.dart';

@RoutePage()
class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<void> authState = ref.watch(authControllerProvider);
    final AuthController authController =
        ref.read(authControllerProvider.notifier);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFFFF9800),
              Color(0xFFFFEB3B), // 仮背景
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                context.l10n.app_name,
                style: context.textTheme.displayLarge?.copyWith(
                  color: context.colorScheme.surface,
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              SignInButton(
                text: context.l10n.signin_with_guest,
                Buttons.anonymous,
                onPressed: () async {
                  await authController.signInAnonymously();
                  if (!context.mounted) return;
                  if (authState.hasError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.l10n
                              .signin_failure(authState.error.toString()),
                        ),
                      ),
                    );
                  } else {
                    context.router.replace(const HomeRoute());
                  }
                },
              ),
              SignInButton(
                Buttons.google,
                onPressed: () async {
                  await authController.signInWithGoogle();
                  if (!context.mounted) return;
                  if (authState.hasError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.l10n
                              .signin_failure(authState.error.toString()),
                        ),
                      ),
                    );
                  } else {
                    context.router.replace(const HomeRoute());
                  }
                },
              ),
              SignInButton(
                Buttons.twitter,
                onPressed: () async {
                  await authController.signInWithTwitter();
                  if (!context.mounted) return;
                  if (authState.hasError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.l10n
                              .signin_failure(authState.error.toString()),
                        ),
                      ),
                    );
                  } else {
                    context.router.replace(const HomeRoute());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
