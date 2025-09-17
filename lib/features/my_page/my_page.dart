import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/utils/context_extension.dart';
import '../../core/auth/controller/auth_controller.dart';
import '../../core/auth/data/auth_state.dart';
import '../../core/auth/providers.dart';
import '../../core/router/app_router.gr.dart';
import '../../core/utils/sort_items_extension.dart';
import '../../core/widgets/bottom_sheet/my_qr_bottom_sheet.dart';
import 'view/linca_vertical.dart';
import 'view/my_page_item.dart';

@RoutePage()
class MyPage extends HookConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AuthState> authState = ref.watch(authControllerProvider);
    final AuthController authController =
        ref.read(authControllerProvider.notifier);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Hero(
                tag: 'LinCaCard',
                child: LincaVertical(
                  name: 'ふぇふぇ',
                  avatar: const AssetImage('assets/images/user.png'),
                  seriesChips: const <SeriesTag>[
                    SeriesTag.muse,
                    SeriesTag.aqours,
                    SeriesTag.nijigasaki,
                    SeriesTag.liella,
                    SeriesTag.hasunosora,
                    SeriesTag.ikizulive,
                    SeriesTag.collaborative,
                  ],
                  bio:
                      '''現地参戦メイン。物販列情報はXで共有します！現地参戦メイン。物販列情報はXで共有します！現地参戦メイン。物販列情報はXで共有します！現地参戦メイン。物販列情報はXで共有します！現地参戦メイン。物販列情報はXで共有します！
                ''',
                  tintColor: Colors.purple,
                  onTap: () => context.router.push(const LincaDetailRoute()),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                context.l10n.common_linca_card,
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              MyPageItem(
                title: context.l10n.traded_linca_list_title,
                onClickItem: () {
                  // TODO: 交換済みLinCaカード一覧画面へ
                },
              ),
              MyPageItem(
                title: context.l10n.my_qr_code_title,
                onClickItem: () => MyQRBottomSheet.show(context),
              ),
              MyPageItem(
                title: context.l10n.edit_my_linca_title,
                onClickItem: () {
                  // TODO: マイLinCa編集画面へ
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存に成功しました')));
                },
              ),
              MyPageItem(
                title: context.l10n.obtained_badges_title,
                onClickItem: () {
                  // TODO: 獲得バッジ一覧画面へ
                },
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.common_event,
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              MyPageItem(
                title: context.l10n.created_events_title,
                onClickItem: () {
                  // TODO: 作成したイベント一覧画面へ
                },
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.common_setting,
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              MyPageItem(
                title: context.l10n.app_settings_title,
                onClickItem: () => openAppSettings(),
              ),
              MyPageItem(
                title: context.l10n.link_to_google_account,
                subtitle: authState.value?.isGoogleLinked == true
                    ? context.l10n.already_linked
                    : context.l10n.not_linked,
                trailing: authState.value?.isGoogleLinked == true
                    ? ElevatedButton(
                        onPressed: () {},
                        child: Text(context.l10n.release_link),
                      )
                    : null,
                onClickItem: authState.value?.isGoogleLinked == true
                    ? () {}
                    : () async {
                        await authController.linkGoogle();
                        if (!context.mounted) return;
                        final String message = authState.hasError == true
                            ? context.l10n
                                .signin_failure(authState.error.toString())
                            : context.l10n.success_link_account;

                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(message)));
                      },
              ),
              MyPageItem(
                title: context.l10n.link_to_x_account,
                subtitle: authState.value?.isTwitterLinked == true
                    ? context.l10n.already_linked
                    : context.l10n.not_linked,
                trailing: authState.value?.isTwitterLinked == true
                    ? ElevatedButton(
                        onPressed: () {},
                        child: Text(context.l10n.release_link),
                      )
                    : null,
                onClickItem: authState.value?.isTwitterLinked == true
                    ? () {}
                    : () async {
                        await authController.linkTwitter();
                        if (!context.mounted) return;
                        final String message = authState.hasError == true
                            ? context.l10n
                                .signin_failure(authState.error.toString())
                            : context.l10n.success_link_account;

                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(message)));
                      },
              ),
              MyPageItem(
                title: context.l10n.sign_out,
                trailing: null,
                onClickItem: () {
                  // TODO: サインアウトダイアログ表示
                  authController.signOut();
                  context.router.replace(const LoginRoute());
                },
              ),
              const SizedBox(height: 32),
              MyPageItem(
                title: context.l10n.delete_account_title,
                trailing: null,
                onClickItem: () {
                  // TODO: アカウント削除ダイアログ表示
                  authController.deleteMyAccount();
                  context.router.replace(const LoginRoute());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
