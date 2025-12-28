import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/linca_user.dart';
import 'package:linca_otaku_support/features/onboarding/view/tutorial_custom_step_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/utils/context_extension.dart';
import '../../core/asset_gen/assets.gen.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/controller/user_controller.dart';
import '../../core/network/providers.dart';
import '../../core/router/app_router.gr.dart';
import 'data/onboarding_state.dart';
import 'view/tutorial_input_nickname_page.dart';
import 'view_model/onboarding_view_model.dart';

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
    final LincaUser? user = ref.watch(userControllerProvider).value;
    final List<Widget> pages = <Widget>[
      TutorialCustomStepPage(
        content: GridView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.6,
          ),
          children: <Widget>[
            Image.asset(Assets.images.lovelive.path, fit: BoxFit.contain),
            Image.asset(Assets.images.sunshine.path, fit: BoxFit.contain),
            Image.asset(Assets.images.nijigasaki.path, fit: BoxFit.contain),
            Image.asset(Assets.images.superstar.path, fit: BoxFit.contain),
            SvgPicture.asset(Assets.images.hasunosora.path,
                fit: BoxFit.contain),
            Image.asset(Assets.images.ikizulive.path, fit: BoxFit.contain),
            Image.asset(Assets.images.yohane.path, fit: BoxFit.contain),
            Image.asset(Assets.images.musical.path, fit: BoxFit.contain),
          ],
        ),
        title: context.l10n.onboarding_step1_title,
        description: context.l10n.onboarding_step1_description,
      ),
      TutorialCustomStepPage(
        content: Image.asset(
          Assets.images.onboardingStep2.path,
          fit: BoxFit.contain,
        ),
        title: context.l10n.onboarding_step2_title,
        description: context.l10n.onboarding_step2_description,
      ),
      TutorialCustomStepPage(
        content: Image.asset(
          Assets.images.onboardingStep3.path,
          width: 250,
          fit: BoxFit.contain,
        ),
        title: context.l10n.onboarding_step3_title,
        description: context.l10n.onboarding_step3_description,
      ),
      TutorialInputNicknamePage(
        nicknameKey: nicknameKey,
        lincaUser: user,
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
        await userController.updateDisplayName(onboardingState.nickname);
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
      body: SafeArea(
        child: Column(
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
                child: Text(
                  isLastPage.value
                      ? context.l10n.common_start
                      : context.l10n.common_next,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
