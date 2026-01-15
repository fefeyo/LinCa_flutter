import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/analytics_screen.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/screen_analytics_manager.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

@RoutePage()
class QrCodeReadPage extends HookConsumerWidget with ScreenAnalyticsManager {
  const QrCodeReadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logScreen(AnalyticsScreen.readQR);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          /// カメラビュー
          MobileScanner(
            controller: MobileScannerController(),
            onDetect: (BarcodeCapture capture) {
              final String? code = capture.barcodes.first.rawValue;
              if (code != null) {
                context.router.pop(code);
              }
            },
          ),

          /// □の読み取りガイド枠
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),

          /// フェードアウトマスク（中央以外を暗くする）
          _ScannerOverlayMask(),

          Positioned(
            left: 0,
            right: 0,
            bottom: 300,
            child: Text(
              context.l10n.qr_hold_up_message,
              textAlign: TextAlign.center,
              style:
                  context.textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// 中央以外を暗くするマスク
class _ScannerOverlayMask extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          final double height = constraints.maxHeight;
          const double boxSize = 250;

          return Stack(
            children: <Widget>[
              // 上
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: (height - boxSize) / 2,
                child: Container(color: Colors.black.withValues(alpha: 0.5)),
              ),
              // 下
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: (height - boxSize) / 2,
                child: Container(color: Colors.black.withValues(alpha: 0.5)),
              ),
              // 左
              Positioned(
                top: (height - boxSize) / 2,
                left: 0,
                width: (width - boxSize) / 2,
                height: boxSize,
                child: Container(color: Colors.black.withValues(alpha: 0.5)),
              ),
              // 右
              Positioned(
                top: (height - boxSize) / 2,
                right: 0,
                width: (width - boxSize) / 2,
                height: boxSize,
                child: Container(color: Colors.black.withValues(alpha: 0.5)),
              ),
            ],
          );
        },
      ),
    );
  }
}
