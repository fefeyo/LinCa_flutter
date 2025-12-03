import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/models/linca_user.dart';
import '../../../core/utils/context_extension.dart';
import '../data/onboarding_state.dart';
import '../view_model/onboarding_view_model.dart';

class TutorialInputNicknamePage extends HookConsumerWidget {
  const TutorialInputNicknamePage({
    super.key,
    required this.nicknameKey,
    this.lincaUser,
  });

  final GlobalKey<FormState> nicknameKey;
  final LincaUser? lincaUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState state = ref.watch(onboardingViewModelProvider);
    final OnboardingViewModel viewModel =
        ref.read(onboardingViewModelProvider.notifier);
    final TextEditingController controller =
        useTextEditingController(text: state.nickname);

    useEffect(() {
      final String? name = lincaUser?.user.displayName;
      if (name != null) {
        controller.text = name;
        Future<void>.microtask(() {
          viewModel.setNickName(name);
        });
      }

      return null;
    }, const <Object?>[]);

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
                    onChanged: viewModel.setNickName,
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
