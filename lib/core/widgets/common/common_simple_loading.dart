import 'package:flutter/material.dart';

class CommonSimpleLoading extends StatelessWidget {
  const CommonSimpleLoading({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(),
      );
}
