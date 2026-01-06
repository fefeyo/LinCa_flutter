import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/router/app_router.gr.dart';
import '../../core/utils/context_extension.dart';
import 'initial_load_controller.dart';

@RoutePage()
class InitialLoadPage extends HookConsumerWidget {
  const InitialLoadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final InitialLoadState state = ref.watch(initialLoadControllerProvider);
    final InitialLoadController controller =
        ref.read(initialLoadControllerProvider.notifier);

    useEffect(() {
      Future<void>.microtask(controller.load);
      return null;
    }, const <Object?>[]);

    ref.listen<InitialLoadState>(initialLoadControllerProvider,
        (InitialLoadState? previous, InitialLoadState next) {
      if (previous?.isComplete != true && next.isComplete && !next.hasError) {
        context.router.replace(const HomeRoute());
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                context.l10n.initial_load_title,
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: state.steps.isEmpty
                    ? 0.0
                    : state.completedCount / state.steps.length,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.initial_load_progress(
                  state.completedCount,
                  state.steps.length,
                ),
                style: context.textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: state.steps.length,
                  separatorBuilder: (_, __) => const Divider(height: 16),
                  itemBuilder: (BuildContext context, int index) {
                    final InitialLoadStep step = state.steps[index];
                    final bool isCompleted = index < state.completedCount;
                    final bool isActive = step == state.currentStep;
                    return Row(
                      children: <Widget>[
                        Icon(
                          isCompleted
                              ? Icons.check_circle
                              : isActive
                                  ? Icons.autorenew
                                  : Icons.radio_button_unchecked,
                          color: isCompleted
                              ? context.colorScheme.primary
                              : context.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _stepLabel(context, step),
                            style: context.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (state.hasError) ...<Widget>[
                const SizedBox(height: 16),
                Text(
                  context.l10n.initial_load_error,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.error.toString(),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: state.isLoading ? null : controller.load,
                  child: Text(context.l10n.initial_load_retry),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _stepLabel(BuildContext context, InitialLoadStep step) {
    switch (step) {
      case InitialLoadStep.badges:
        return context.l10n.initial_load_badges;
      case InitialLoadStep.groups:
        return context.l10n.initial_load_groups;
      case InitialLoadStep.tags:
        return context.l10n.initial_load_tags;
      case InitialLoadStep.venues:
        return context.l10n.initial_load_venues;
      case InitialLoadStep.user:
        return context.l10n.initial_load_user;
      case InitialLoadStep.events:
        return context.l10n.initial_load_events;
      case InitialLoadStep.userEvents:
        return context.l10n.initial_load_user_events;
      case InitialLoadStep.participations:
        return context.l10n.initial_load_participations;
    }
  }
}
