import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/analytics_event.dart';
import 'package:linca_otaku_support/core/constants/analytics_screen.dart';
import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:linca_otaku_support/core/models/linca_user.dart';
import 'package:linca_otaku_support/core/network/controller/user_controller.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/event_analytics_manager.dart';
import 'package:linca_otaku_support/core/utils/screen_analytics_manager.dart';
import 'package:linca_otaku_support/core/widgets/bottom_sheet/my_qr_bottom_sheet.dart';
import 'package:linca_otaku_support/features/my_page/view/linca_vertical.dart';

import '../../core/router/app_router.gr.dart';
import 'data/traded_linca_list_state.dart';
import 'view_model/traded_linca_list_view_model.dart';

@RoutePage()
class TradedLincaListPage extends HookConsumerWidget
    with ScreenAnalyticsManager, EventAnalyticsManager {
  const TradedLincaListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logScreen(AnalyticsScreen.tradedLincaCardList);

    final TradedLincaListState state =
        ref.watch(tradedLincaListViewModelProvider);
    final UserController userController =
        ref.read(userControllerProvider.notifier);
    final ValueNotifier<bool> isLoading = useState(true);

    useEffect(() {
      Future<void>.microtask(() async {
        await userController.updateFriends();
        isLoading.value = false;
      });

      return null;
    }, const <Object?>[]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.traded_linca_list_title,
          style: context.textTheme.titleMedium,
        ),
      ),
      body: isLoading.value
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : state.friends.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 16,
                  ),
                  child: ListView.separated(
                    itemCount: state.friends.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 16);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      final LincaUser lincaUser = state.friends[index];
                      return LincaVertical(
                          lincaUser: lincaUser,
                          animationTag:
                              '${AppConstants.heroTagLincaCardFriend}$index',
                          onTap: (LincaUser lincaUser, String animationTag) {
                            logEvent(event: AnalyticsEvent.simpleLincaCardTap);

                            context.router.push(
                              LincaDetailRoute(
                                lincaUser: lincaUser,
                                animationTag: animationTag,
                              ),
                            );
                          });
                    },
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        context.l10n.traded_linca_list_empty_title,
                        style: context.textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: () => MyQRBottomSheet.show(context),
                        child:
                            Text(context.l10n.traded_linca_list_empty_button),
                      )
                    ],
                  ),
                ),
    );
  }
}
