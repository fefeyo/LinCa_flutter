#!/bin/bash

# エラー発生時にスクリプトを停止
set -e

echo "🏗️ Running build_runner..."

dart run build_runner build --delete-conflicting-outputs

echo "✅ build_runner build completed."
