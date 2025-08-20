#!/bin/bash

# エラー発生時にスクリプトを停止
set -e

echo "🧹 Cleaning Flutter project..."

fvm flutter clean
rm -rf pubspec.lock .dart_tool build

echo "✅ Clean completed."
