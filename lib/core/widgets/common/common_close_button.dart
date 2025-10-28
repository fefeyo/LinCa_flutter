import 'package:flutter/material.dart';

class CommonCloseButton extends StatelessWidget {
  const CommonCloseButton({
    super.key,
    required this.onClose,
  });

  final Function() onClose;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.close, color: Colors.white),
      style: IconButton.styleFrom(
        backgroundColor: Colors.black26,
        shape: const CircleBorder(),
        fixedSize: const Size(48, 48),
        padding: EdgeInsets.zero,
      ),
      onPressed: onClose,
    );
  }
}
