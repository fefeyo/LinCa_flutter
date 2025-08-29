import 'package:fefeyo_flutter_template/core/utils/context_extension.dart';
import 'package:fefeyo_flutter_template/features/onboarding/data/onboarding_state.dart';
import 'package:fefeyo_flutter_template/features/onboarding/view_model/onboarding_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TutorialInputNicknamePage extends HookConsumerWidget {
  const TutorialInputNicknamePage({
    super.key,
    required this.nicknameKey,
  });

  final GlobalKey<FormState> nicknameKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState onboardingState =
        ref.watch(onboardingViewModelProvider);
    final OnboardingViewModel onboardingViewModel =
        ref.read(onboardingViewModelProvider.notifier);
    final TextEditingController controller =
        useTextEditingController(text: onboardingState.nickname);

    String? validate(String? input) {
      final List<String> forbiddenChars = <String>[
        '/',
        '.',
        '#',
        r'$',
        '[',
        ']'
      ];

      for (final String char in forbiddenChars) {
        if (input?.contains(char) == true) {
          return '使用できない文字 "$char" が含まれています。';
        }
      }

      return null;
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Form(
            key: nicknameKey,
            child: SizedBox(
              height: 350,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextFormField(
                    controller: controller,
                    validator: validate,
                    decoration: const InputDecoration(
                      labelText: 'ニックネーム',
                      hintText: '例：幻の学院生',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 20,
                    onChanged: onboardingViewModel.setNickName,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.onboarding_step4_title,
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.onboarding_step4_description,
            style: context.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
