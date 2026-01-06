import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/auth/providers.dart';
import '../../core/network/providers.dart';

enum InitialLoadStep {
  badges,
  groups,
  tags,
  venues,
  user,
  events,
  userEvents,
  participations,
}

class InitialLoadState {
  const InitialLoadState({
    required this.steps,
    this.completedCount = 0,
    this.currentStep,
    this.isLoading = false,
    this.error,
    this.stackTrace,
  });

  final List<InitialLoadStep> steps;
  final int completedCount;
  final InitialLoadStep? currentStep;
  final bool isLoading;
  final Object? error;
  final StackTrace? stackTrace;

  bool get hasError => error != null;

  bool get isComplete => completedCount >= steps.length;

  InitialLoadState copyWith({
    int? completedCount,
    InitialLoadStep? currentStep,
    bool? isLoading,
    Object? error,
    StackTrace? stackTrace,
    bool clearError = false,
  }) {
    return InitialLoadState(
      steps: steps,
      completedCount: completedCount ?? this.completedCount,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      stackTrace: clearError ? null : stackTrace ?? this.stackTrace,
    );
  }
}

final StateNotifierProvider<InitialLoadController, InitialLoadState>
    initialLoadControllerProvider =
    StateNotifierProvider<InitialLoadController, InitialLoadState>((Ref ref) {
  return InitialLoadController(ref);
});

class InitialLoadController extends StateNotifier<InitialLoadState> {
  InitialLoadController(this.ref)
      : super(const InitialLoadState(steps: InitialLoadStep.values));

  final Ref ref;

  Future<void> load() async {
    state = state.copyWith(
      completedCount: 0,
      currentStep: null,
      isLoading: true,
      clearError: true,
    );

    final bool isLoggedIn =
        ref.read(firebaseAuthProvider).currentUser != null;
    if (!isLoggedIn) {
      state = state.copyWith(
        completedCount: state.steps.length,
        isLoading: false,
      );
      return;
    }

    try {
      await _runStepsInParallel(<InitialLoadStep>[
        InitialLoadStep.badges,
        InitialLoadStep.groups,
        InitialLoadStep.tags,
        InitialLoadStep.venues,
      ], <Future<Object?> Function()>[
        () => ref.read(badgeControllerProvider.future),
        () => ref.read(groupControllerProvider.future),
        () => ref.read(tagControllerProvider.future),
        () => ref.read(venueControllerProvider.future),
      ]);
      await _runStep(
        InitialLoadStep.user,
        () => ref.read(userControllerProvider.future),
      );
      await _runStepsInParallel(<InitialLoadStep>[
        InitialLoadStep.events,
        InitialLoadStep.userEvents,
      ], <Future<Object?> Function()>[
        () => ref.read(eventControllerProvider.future),
        () => ref.read(userEventControllerProvider.future),
      ]);
      await _runStep(
        InitialLoadStep.participations,
        () => ref.read(participationControllerProvider.future),
      );
      state = state.copyWith(
        isLoading: false,
        currentStep: null,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        isLoading: false,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _runStep(
    InitialLoadStep step,
    Future<Object?> Function() action,
  ) async {
    state = state.copyWith(currentStep: step);
    await action();
    state = state.copyWith(completedCount: state.completedCount + 1);
  }

  Future<void> _runStepsInParallel(
    List<InitialLoadStep> steps,
    List<Future<Object?> Function()> actions,
  ) async {
    await Future.wait(<Future<void>>[
      for (int i = 0; i < steps.length; i++)
        _runStep(steps[i], actions[i]),
    ]);
  }
}
