#!/bin/bash

# Flutter プロジェクトのルートで実行することを想定
echo "Running flutter pub get..."
flutter pub get

# 成功/失敗のチェック
if [ $? -eq 0 ]; then
  echo "✅ flutter pub get completed successfully!"
else
  echo "❌ flutter pub get failed!"
  exit 1
fi
