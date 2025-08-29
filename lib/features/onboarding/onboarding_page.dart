import 'package:fefeyo_flutter_template/core/constants/app_constants.dart';
import 'package:fefeyo_flutter_template/core/network/controller/user_controller.dart';
import 'package:fefeyo_flutter_template/core/network/providers.dart';
import 'package:fefeyo_flutter_template/core/router/app_router.gr.dart';
import 'package:fefeyo_flutter_template/core/utils/context_extension.dart';
import 'package:fefeyo_flutter_template/features/onboarding/data/onboarding_state.dart';
import 'package:fefeyo_flutter_template/features/onboarding/view/tutorial_input_nickname_page.dart';
import 'package:fefeyo_flutter_template/features/onboarding/view/tutorial_step_page.dart';
import 'package:fefeyo_flutter_template/features/onboarding/view_model/onboarding_view_model.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/asset_gen/assets.gen.dart';

@RoutePage()
class OnboardingPage extends HookConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState onboardingState =
        ref.watch(onboardingViewModelProvider);
    final PageController controller = PageController();
    final ValueNotifier<bool> isLastPage = useState(false);
    final GlobalKey<FormState> nicknameKey =
        useMemoized(() => GlobalKey<FormState>());
    final bool cannotMoveNextPage = onboardingState.nickname.isNotEmpty &&
        nicknameKey.currentState?.validate() == false;
    final UserController userController =
        ref.read(userControllerProvider.notifier);
    final List<Widget> pages = <Widget>[
      TutorialStepPage(
        animation: Assets.lottie.tutorial1,
        title: context.l10n.onboarding_step1_title,
        description: context.l10n.onboarding_step1_description,
      ),
      TutorialStepPage(
        animation: Assets.lottie.tutorial2,
        title: context.l10n.onboarding_step2_title,
        description: context.l10n.onboarding_step2_description,
      ),
      TutorialStepPage(
        animation: Assets.lottie.tutorial3,
        title: context.l10n.onboarding_step3_title,
        description: context.l10n.onboarding_step3_description,
      ),
      TutorialInputNicknamePage(
        nicknameKey: nicknameKey,
      ),
      TutorialStepPage(
        animation: Assets.lottie.tutorialComplete,
        title: context.l10n.onboarding_step5_title,
        description: context.l10n.onboarding_step5_description,
      ),
    ];

    void goToNextPage() async {
      if (cannotMoveNextPage) return;
      if (!isLastPage.value) {
        controller.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        if (onboardingState.nickname.isNotEmpty) {
          await userController.updateDisplayName(onboardingState.nickname);
        }
        final SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setBool(AppConstants.hasSeenOnboarding, true);
        if (context.mounted) {
          context.router.push(const HomeRoute());
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView.builder(
              controller: controller,
              itemCount: pages.length,
              physics: cannotMoveNextPage
                  ? const NeverScrollableScrollPhysics()
                  : const ClampingScrollPhysics(),
              onPageChanged: (int index) {
                isLastPage.value = index == pages.length - 1;
              },
              itemBuilder: (_, int index) => pages[index],
            ),
          ),
          SmoothPageIndicator(
            controller: controller,
            count: pages.length,
            effect: WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              spacing: 12,
              activeDotColor: context.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: goToNextPage,
              child: Text(isLastPage.value ? 'はじめる' : '次へ'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
