import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:linca_otaku_support/core/models/user_profile.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/widgets/bottom_sheet/my_qr_bottom_sheet.dart';
import 'package:linca_otaku_support/features/my_page/view/linca_vertical.dart';

import '../../core/router/app_router.gr.dart';
import 'data/traded_linca_list_state.dart';
import 'view_model/traded_linca_list_view_model.dart';

@RoutePage()
class TradedLincaListPage extends HookConsumerWidget {
  const TradedLincaListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TradedLincaListState state =
        ref.watch(tradedLincaListViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.traded_linca_list_title)),
      body: state.friends.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView.separated(
                itemCount: state.friends.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 16);
                },
                itemBuilder: (BuildContext context, int index) {
                  final UserProfile userProfile = state.friends[index];
                  return LincaVertical(
                    userProfile: userProfile,
                    animationTag: AppConstants.heroTagLincaCardFriend,
                    onTap: (UserProfile userProfile, String animationTag) =>
                        context.router.push(
                      LincaDetailRoute(
                        userProfile: userProfile,
                        animationTag: animationTag,
                      ),
                    ),
                  );
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
                    child: Text(context.l10n.traded_linca_list_empty_button),
                  )
                ],
              ),
            ),
    );
  }
}
