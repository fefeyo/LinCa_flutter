#!/bin/bash

# エラー発生時に停止
set -e

# .envがなければコピー
if [ ! -f .env ]; then
  cp .env.example .env
  echo "✅ .env created from .env.example"
else
  echo "ℹ️ .env already exists"
fi
