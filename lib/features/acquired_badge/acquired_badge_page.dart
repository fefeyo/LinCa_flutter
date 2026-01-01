import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/analytics_screen.dart';
import 'package:linca_otaku_support/core/models/linca_user.dart';
import 'package:linca_otaku_support/core/network/controller/user_controller.dart';
import 'package:linca_otaku_support/core/network/model/linca_badge.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/screen_analytics_manager.dart';

@RoutePage()
class AcquiredBadgePage extends HookConsumerWidget with ScreenAnalyticsManager {
  const AcquiredBadgePage({
    super.key,
    this.selectable = false,
  });

  final bool selectable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logScreen(AnalyticsScreen.acquiredBadgeList);

    final LincaUser? lincaUser = ref.watch(userControllerProvider).value;
    final UserController userController =
        ref.read(userControllerProvider.notifier);
    final List<LincaBadge?> acquiredBadges = <LincaBadge?>[
      if (selectable) null,
      ...lincaUser?.acquiredBadges ?? <LincaBadge>[],
    ];

    useEffect(() {
      Future<void>.microtask(() {
        userController.updateAcquiredBadges();
      });

      return null;
    }, const <Object?>[]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectable ? 'バッジ選択' : '獲得済みバッジ一覧',
          style: context.textTheme.titleMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: acquiredBadges.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemBuilder: (BuildContext context, int index) {
            final LincaBadge? item = acquiredBadges[index];

            return GestureDetector(
              onTap: selectable
                  ? item != null
                      ? () => context.router.pop(item)
                      : () => context.router.pop(LincaBadge.unselected)
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: item == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(Icons.cancel, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              '未選択',
                              style: context.textTheme.bodySmall,
                            ),
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: item.iconUrl.isNotEmpty
                                    ? CachedNetworkImage(imageUrl: item.iconUrl)
                                    : const Icon(
                                        Icons.device_unknown,
                                        size: 40,
                                      ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  item.name,
                                  style: context.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
