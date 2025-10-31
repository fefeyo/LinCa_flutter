import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/widgets/common/common_simple_loading.dart';

class CommonSimpleLoadingDialog extends StatelessWidget {
  const CommonSimpleLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonSimpleLoading();
  }

  static Future<bool?> show({required BuildContext context}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext context) => const CommonSimpleLoadingDialog(),
    );
  }
}
