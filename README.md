# fefeyo_flutter_template

## アプリ概要（名称・目的）
* 名称: fefeyo_flutter_template
* 目的: Flutter + Firebase を前提としたアプリ開発のひな形（認証/状態管理/コード生成など）を提供する。

## 開発環境要件（Flutter バージョン、Dart SDK）
* Flutter: 3.22.x 以上（推奨: stable チャンネル）
* Dart SDK: Flutter 同梱版（目安: 3.4.x 以上）

## セットアップ手順（flutterfire 設定、必要な .env/.dart-define など）
1. 依存関係を取得
   ```bash
   flutter pub get
   ```
2. FlutterFire CLI を用意
   ```bash
   dart pub global activate flutterfire_cli
   ```
3. Firebase プロジェクトへ紐付け
   ```bash
   flutterfire configure
   ```
4. 必要に応じて .env / --dart-define を準備
   * `.env` を利用する場合は、プロジェクト直下に作成する。
   * `--dart-define` で環境変数を渡す場合:
     ```bash
     flutter run \
       --dart-define=ENV=dev \
       --dart-define=API_BASE_URL=https://example.com
     ```

## コード生成コマンド（build_runner / flutter_gen / l10n）
* build_runner
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```
* flutter_gen（アセット/フォント等）
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```
* l10n（多言語）
  ```bash
  flutter gen-l10n
  ```

## 主要ディレクトリ構成の簡単な説明
* `lib/`: アプリ本体のソースコード
* `assets/`: 画像・フォントなどのアセット
* `android/`, `ios/`: ネイティブ実装/設定
* `functions/`: Firebase Functions（必要に応じて）
* `test/`: テストコード
* `scripts/`: 補助スクリプト
