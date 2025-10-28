import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/auth/providers.dart';
import 'package:linca_otaku_support/core/network/controller/friend_controller.dart';
import 'package:linca_otaku_support/core/network/controller/user_controller.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import 'package:linca_otaku_support/core/router/app_router.gr.dart';

import '../../../core/utils/context_extension.dart';
import '../../../core/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyQRBottomSheet extends HookConsumerWidget {
  const MyQRBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? uid = ref.watch(uidProvider);
    final FriendController friendController =
        ref.read(friendControllerProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // ← キーボード重なり対策
        ),
        child: SafeArea(
          bottom: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: double.infinity,
              maxHeight: 480,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  QrImageView(
                    data: uid!.buildLinCaUri(),
                    version: QrVersions.auto,
                    size: 300,
                    gapless: true,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: context.colorScheme.onSurface,
                    ),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.qr_share_message,
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final String? result = await context.router
                          .push<String>(const QrCodeReadRoute());
                      if (result != null) {
                        final String friendUid = result.userId;
                        await friendController.registerFriend(friendUid);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  context.l10n.my_qr_code_success_linca_trade),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(
                      context.l10n.my_qr_code_transit_scan,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colorScheme.surface,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> show(BuildContext context) async => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) => const MyQRBottomSheet());
}
