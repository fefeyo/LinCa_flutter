import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/analytics_event.dart';
import 'package:linca_otaku_support/core/constants/analytics_screen.dart';
import 'package:linca_otaku_support/core/models/linca_user.dart';
import 'package:linca_otaku_support/core/utils/event_analytics_manager.dart';
import 'package:linca_otaku_support/core/utils/linca_user_extension.dart';
import 'package:linca_otaku_support/core/utils/preferences_service.dart';
import 'package:linca_otaku_support/core/utils/screen_analytics_manager.dart';
import 'package:linca_otaku_support/core/widgets/common/common_simple_dialog.dart';
import 'package:linca_otaku_support/features/my_page/data/my_page_state.dart';
import 'package:linca_otaku_support/features/my_page/view_model/my_page_view_model.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/context_extension.dart';
import '../../core/auth/controller/auth_controller.dart';
import '../../core/auth/data/auth_state.dart';
import '../../core/auth/providers.dart';
import '../../core/router/app_router.gr.dart';
import '../../core/utils/providers.dart';
import '../../core/widgets/bottom_sheet/my_qr_bottom_sheet.dart';
import 'view/linca_vertical.dart';
import 'view/my_page_item.dart';

@RoutePage()
class MyPage extends HookConsumerWidget
    with ScreenAnalyticsManager, EventAnalyticsManager {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logScreen(AnalyticsScreen.myPage);

    final AsyncValue<AuthState> authState = ref.watch(authControllerProvider);
    final AuthController authController =
        ref.read(authControllerProvider.notifier);
    final MyPageState state = ref.watch(myPageViewModelProvider);
    final PreferencesService preferencesService =
        ref.read(preferencesServiceProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LincaVertical(
                  lincaUser: state.lincaUser,
                  animationTag: AppConstants.heroTagLincaCardMyPage,
                  onTap: (LincaUser lincaUser, String animationTag) {
                    logEvent(event: AnalyticsEvent.simpleLincaCardTap);
                    context.router.push(
                      LincaDetailRoute(
                        lincaUser: lincaUser,
                        animationTag: animationTag,
                      ),
                    );
                  }),
              const SizedBox(height: 32),
              Text(
                context.l10n.common_linca_card,
                style: context.textTheme.titleSmall,
              ),
              const SizedBox(height: 16),
              MyPageItem(
                title: context.l10n.edit_my_linca_title,
                onClickItem: () {
                  logEvent(event: AnalyticsEvent.openEditMyLincaCardClick);

                  context.router.push(
                    LincaEditRoute(
                      userProfile: state.lincaUser.userProfile,
                    ),
                  );
                },
              ),
              MyPageItem(
                title: context.l10n.traded_linca_list_title,
                onClickItem: () {
                  logEvent(event: AnalyticsEvent.openTradedLincaCardClick);

                  context.router.push(const TradedLincaListRoute());
                },
              ),
              MyPageItem(
                title: context.l10n.my_qr_code_title,
                onClickItem: () {
                  logEvent(event: AnalyticsEvent.openLincaQRClick);

                  MyQRBottomSheet.show(context);
                },
              ),
              MyPageItem(
                title: context.l10n.acquired_badges_title,
                onClickItem: () {
                  logEvent(event: AnalyticsEvent.openAcquiredBadgeListClick);

                  context.router.push(AcquiredBadgeRoute());
                },
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.common_event,
                style: context.textTheme.titleSmall,
              ),
              const SizedBox(height: 16),
              MyPageItem(
                title: context.l10n.highlight_title,
                onClickItem: () {
                  logEvent(event: AnalyticsEvent.openHighLightClick);

                  context.router.push(const HighlightRoute());
                },
              ),
              MyPageItem(
                title: context.l10n.event_output_title,
                onClickItem: () {
                  context.router.push(const OutputParticipateEventsRoute());
                },
              ),
              MyPageItem(
                title: context.l10n.created_events_title,
                onClickItem: () {
                  logEvent(event: AnalyticsEvent.openCreatedEventListClick);

                  context.router.push(const CreatedEventListRoute());
                },
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.common_setting,
                style: context.textTheme.titleSmall,
              ),
              const SizedBox(height: 16),
              MyPageItem(
                title: context.l10n.app_settings_title,
                onClickItem: () {
                  logEvent(event: AnalyticsEvent.openAppSettingsClick);

                  openAppSettings();
                },
              ),
              MyPageItem(
                title: context.l10n.link_to_google_account,
                subtitle: authController.isGoogleLinked()
                    ? context.l10n.already_linked
                    : context.l10n.not_linked,
                trailing: authController.isBothProviderLinked()
                    ? ElevatedButton(
                        onPressed: () async {
                          logEvent(
                              event: AnalyticsEvent.googleAccountUnLinkClick);

                          await authController.unLinkGoogle();
                          ref.invalidate(authControllerProvider);
                          if (!context.mounted) return;
                          context.showSuccessSnackBar(
                              message: context.l10n.success_unlink_account);
                        },
                        child: Text(
                          context.l10n.release_link,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
                onClickItem: authController.isGoogleLinked()
                    ? () {}
                    : () async {
                        logEvent(event: AnalyticsEvent.googleAccountLinkClick);

                        final bool isSignedIn =
                            await authController.linkGoogle();
                        if (!context.mounted || !isSignedIn) {
                          return;
                        }
                        if (!authState.hasError) {
                          context.showSuccessSnackBar(
                              message: context.l10n.success_link_account);
                        } else {
                          context.showErrorSnackBar(
                            message: context.l10n.signin_failure(
                              authState.error.toString(),
                            ),
                          );
                        }
                      },
              ),
              MyPageItem(
                title: context.l10n.link_to_x_account,
                subtitle: authController.isTwitterLinked()
                    ? context.l10n.already_linked
                    : context.l10n.not_linked,
                trailing: authController.isBothProviderLinked()
                    ? ElevatedButton(
                        onPressed: () async {
                          logEvent(
                              event: AnalyticsEvent.twitterAccountUnLinkClick);

                          await authController.unLinkTwitter();
                          ref.invalidate(authControllerProvider);
                          if (!context.mounted) return;
                          context.showSuccessSnackBar(
                              message: context.l10n.success_unlink_account);
                        },
                        child: Text(
                          context.l10n.release_link,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
                onClickItem: authController.isTwitterLinked()
                    ? () {}
                    : () async {
                        logEvent(event: AnalyticsEvent.twitterAccountLinkClick);

                        final bool isSignedIn =
                            await authController.linkTwitter();
                        if (!context.mounted || !isSignedIn) {
                          return;
                        }
                        if (!authState.hasError) {
                          context.showSuccessSnackBar(
                              message: context.l10n.success_link_account);
                        } else {
                          context.showErrorSnackBar(
                            message: context.l10n.signin_failure(
                              authState.error.toString(),
                            ),
                          );
                        }
                      },
              ),
              MyPageItem(
                title: context.l10n.sign_out,
                trailing: null,
                onClickItem: () async {
                  logEvent(event: AnalyticsEvent.signOutClick);

                  final bool? comfirmed = await CommonSimpleDialog.show(
                    context: context,
                    title: context.l10n.account_logout_dialog_title,
                    onClickCancel: () {},
                  );
                  if (comfirmed == true && context.mounted) {
                    authController.signOut();
                    preferencesService.clearUserSignInData();
                    context.router.replace(const LoginRoute());
                  }
                },
              ),
              const SizedBox(height: 32),
              MyPageItem(
                title: context.l10n.delete_account_title,
                trailing: null,
                onClickItem: () async {
                  logEvent(event: AnalyticsEvent.deleteMyAccountClick);

                  final bool? comfirmed = await CommonSimpleDialog.show(
                    context: context,
                    title: context.l10n.account_delete_dialog_title,
                    content: context.l10n.account_delete_dialog_description,
                    onClickCancel: () {},
                  );
                  if (comfirmed == true && context.mounted) {
                    authController.deleteMyAccount();
                    preferencesService.clearUserSignInData();
                    context.router.replace(const LoginRoute());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
