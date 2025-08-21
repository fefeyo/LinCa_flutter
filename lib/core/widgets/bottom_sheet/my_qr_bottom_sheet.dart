import 'package:fefeyo_flutter_template/core/utils/context_extension.dart';
import 'package:fefeyo_flutter_template/core/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyQRBottomSheet extends StatelessWidget {
  const MyQRBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // ← キーボード重なり対策
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: double.infinity,
          maxHeight: 500,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              QrImageView(
                data: buildLinCaUri('000001'),
                version: QrVersions.auto,
                size: 300,
                gapless: true,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 32),
              Text(
                'このQRコードをスキャンすると\nあなたのプロフィールが交換されるよ！',
                style: context.textTheme.titleMedium,
              )
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> show(BuildContext context) async => showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => const MyQRBottomSheet());
}
