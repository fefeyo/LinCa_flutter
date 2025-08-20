#!/bin/bash

# エラー発生時にスクリプトを停止
set -e

echo "🎨 Formatting Dart files..."

dart format lib test

echo "✅ Formatting completed."
