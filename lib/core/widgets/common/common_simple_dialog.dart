import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';

class CommonSimpleDialog extends StatelessWidget {
  const CommonSimpleDialog({
    super.key,
    required this.title,
    this.content,
    this.cancelText,
    this.okText,
    this.onClickCancel,
    this.onClickOk,
  });

  final String title;
  final String? content;
  final String? cancelText;
  final String? okText;
  final Function()? onClickCancel;
  final Function()? onClickOk;

  @override
  Widget build(BuildContext context) {
    final String displayCancelText = cancelText ?? context.l10n.common_cancel;
    final String displayOkText = okText ?? context.l10n.common_ok;

    return AlertDialog(
      title: Text(
        title,
        style: context.textTheme.titleMedium,
      ),
      content: content != null
          ? Text(
              content!,
              style: context.textTheme.bodyMedium,
            )
          : null,
      actions: <Widget>[
        if (onClickCancel != null)
          TextButton(
            onPressed: () {
              onClickCancel?.call();
              Navigator.of(context).pop(false);
            },
            child: Text(displayCancelText),
          ),
        TextButton(
          onPressed: () {
            onClickOk?.call();
            Navigator.of(context).pop(true);
          },
          child: Text(displayOkText),
        ),
      ],
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    String? content,
    String? cancelText,
    String? okText,
    Function()? onClickCancel,
    Function()? onClickOk,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CommonSimpleDialog(
          title: title,
          content: content,
          cancelText: cancelText,
          okText: okText,
          onClickCancel: onClickCancel,
          onClickOk: onClickOk),
    );
  }
}
