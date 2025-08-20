#!/bin/bash
set -e

# FVM 経由で Flutter を実行
echo "Running flutter test with FVM..."

# テスト実行
fvm flutter test --reporter expanded
