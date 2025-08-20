#!/bin/bash

# エラー発生時にスクリプトを停止
set -e

echo "🔍 Running Dart analyzer..."

dart analyze

echo "✅ Analysis completed without issues."
