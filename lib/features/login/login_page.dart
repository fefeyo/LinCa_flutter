import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/auth/data/auth_state.dart';
import 'package:linca_otaku_support/core/constants/analytics_event.dart';
import 'package:linca_otaku_support/core/constants/analytics_screen.dart';
import 'package:linca_otaku_support/core/utils/color_extension.dart';
import 'package:linca_otaku_support/core/utils/event_analytics_manager.dart';
import 'package:linca_otaku_support/core/utils/screen_analytics_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../../../core/utils/context_extension.dart';
import '../../core/asset_gen/assets.gen.dart';
import '../../core/auth/controller/auth_controller.dart';
import '../../core/auth/providers.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.gr.dart';

@RoutePage()
class LoginPage extends HookConsumerWidget
    with ScreenAnalyticsManager, EventAnalyticsManager {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logScreen(AnalyticsScreen.login);

    final AsyncValue<AuthState> authState = ref.watch(authControllerProvider);
    final AuthController authController =
        ref.read(authControllerProvider.notifier);

    void actionAfterSignIn(bool isSignedIn) async {
      if (!context.mounted || !isSignedIn) return;
      if (authState.hasError) {
        context.showErrorSnackBar(
          message: context.l10n.signin_failure(authState.error.toString()),
        );
      } else {
        final SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        final bool onboardingShown =
            sharedPreferences.getBool(AppConstants.hasSeenOnboarding) ?? false;
        final PageRouteInfo<void> destination =
            onboardingShown ? const HomeRoute() : const OnboardingRoute();
        if (context.mounted) {
          context.router.replace(destination);
        }
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              context.colorScheme.loginBackground.withValues(alpha: 0.6),
              context.colorScheme.loginBackground.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(Assets.icons.lincaIconFront.path),
              SignInButton(
                text: context.l10n.signin_with_guest,
                Buttons.anonymous,
                onPressed: () async {
                  final bool isSignedIn =
                      await authController.signInAnonymously();

                  logEvent(
                    event: AnalyticsEvent.loginClick,
                    params: <String, Object>{
                      'provider': 'guest',
                      'isSignedIn': isSignedIn ? 1 : 0,
                    },
                  );

                  actionAfterSignIn(isSignedIn);
                },
              ),
              SignInButton(
                Buttons.google,
                onPressed: () async {
                  final bool isSignedIn =
                      await authController.signInWithGoogle();

                  logEvent(
                    event: AnalyticsEvent.loginClick,
                    params: <String, Object>{
                      'provider': 'google',
                      'isSignedIn': isSignedIn ? 1 : 0,
                    },
                  );

                  actionAfterSignIn(isSignedIn);
                },
              ),
              SignInButton(
                Buttons.twitter,
                onPressed: () async {
                  final bool isSignedIn =
                      await authController.signInWithTwitter();

                  logEvent(
                    event: AnalyticsEvent.loginClick,
                    params: <String, Object>{
                      'provider': 'twitter',
                      'isSignedIn': isSignedIn ? 1 : 0,
                    },
                  );

                  actionAfterSignIn(isSignedIn);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
