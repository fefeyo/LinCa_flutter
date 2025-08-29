import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/onboarding_state.dart';

final StateNotifierProvider<OnboardingViewModel, OnboardingState>
    onboardingViewModelProvider =
    StateNotifierProvider<OnboardingViewModel, OnboardingState>(
        (Ref ref) => OnboardingViewModel());

class OnboardingViewModel extends StateNotifier<OnboardingState> {
  OnboardingViewModel() : super(const OnboardingState());

  void setNickName(String nickname) {
    state = state.copyWith(nickname: nickname);
  }
}
