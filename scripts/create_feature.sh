#!/bin/bash

NAME=$1

if [ -z "$NAME" ]; then
  echo "Usage: $0 <feature_name>"
  exit 1
fi

# PascalCase へ変換
CLASS_NAME="$(tr '[:lower:]' '[:upper:]' <<< ${NAME:0:1})${NAME:1}"

BASE_DIR="lib/features/${NAME}"
mkdir -p $BASE_DIR/{data,view,view_model}

# --- data/state ---
cat <<EOF > $BASE_DIR/data/${NAME}_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '${NAME}_state.freezed.dart';
part '${NAME}_state.g.dart';

@freezed
abstract class ${CLASS_NAME}State with _\$${CLASS_NAME}State {
  const factory ${CLASS_NAME}State({
    @Default("") String name,
  }) = _${CLASS_NAME}State;

  factory ${CLASS_NAME}State.fromJson(Map<String, dynamic> json) =>
      _\$${CLASS_NAME}StateFromJson(json);
}
EOF

# --- view_model ---
cat <<EOF > $BASE_DIR/view_model/${NAME}_view_model.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/${NAME}_state.dart';

final ${NAME}ViewModelProvider =
    StateNotifierProvider<${CLASS_NAME}ViewModel, ${CLASS_NAME}State>(
        (ref) => ${CLASS_NAME}ViewModel());

class ${CLASS_NAME}ViewModel extends StateNotifier<${CLASS_NAME}State> {
  ${CLASS_NAME}ViewModel() : super(const ${CLASS_NAME}State());
}
EOF

# --- ページファイル ---
cat <<EOF > $BASE_DIR/${NAME}_page.dart
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'view_model/${NAME}_view_model.dart';

@RoutePage()
class ${CLASS_NAME}Page extends HookConsumerWidget {
  const ${CLASS_NAME}Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(${NAME}ViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('${NAME}')),
      body: Center(
        child: Text(state.name),
      ),
    );
  }
}
EOF

echo "✅ ${NAME} 機能のファイルを生成しました。"
