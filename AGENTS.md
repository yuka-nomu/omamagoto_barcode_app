# Flutter 開発ガイドライン (AGENTS.md)

このドキュメントは、本プロジェクトにおける Flutter 開発の標準指針を定義します。AI エージェントおよび開発者は、以下のルールを遵守してください。

## 1. 基本方針

- **MVP 優先**: 最小限の機能（MVP）を最速で提供することを重視します。
- **シンプル構成**: 過度な抽象化（Clean Architecture の過剰な適用など）を避け、可読性とメンテナンス性を優先します。
- **Material3 採用**: UI デザインは Flutter の Material 3 を基本とします。
- **状態管理**: `riverpod` (flutter_riverpod) を使用します。

## 2. ディレクトリ構造

`lib/` 配下は以下の構造を基本とします。

```text
lib/
├── main.dart            # エントリーポイント
├── app.dart             # MaterialApp 定義
├── core/                # 全体共通（テーマ、定数、共通ユーティリティ）
├── models/              # データモデル（Isar などのスキーマ含む）
├── providers/           # グローバルな状態管理（Riverpod）
├── repositories/        # データアクセス（ローカル保存、設定）
├── screens/             # 各画面（画面ごとにフォルダ分けしない）
│   ├── home_screen.dart
│   ├── product_list_screen.dart
│   ├── ...
├── widgets/             # 複数画面で共有する部品
└── services/            # 外部機能（カメラ、PDF生成、音再生など）
```

## 3. 実装ルール

- **Riverpod**: 状態管理は原則として `NotifierProvider` または `AsyncNotifierProvider` を使用します。コード生成（`riverpod_generator`）の使用を推奨します。
- **UI コンポーネント**: 可能な限り Flutter 標準の Material 3 ウィジェットを使用し、独自の実装を最小限に抑えます。
- **ローカル保存**: 商品データおよび設定の保存には `Isar` または `shared_preferences` を使用します。
- **ひらがな表示**: 設定により UI テキストをひらがなに変更する要件があるため、文字列の扱いに注意してください。
- **エラーハンドリング**: ユーザーに分かりやすいエラーメッセージを表示してください。

## 4. 依存パッケージ（推奨）

- `flutter_riverpod`, `riverpod_annotation`
- `isar`, `isar_flutter_libs`, `path_provider`
- `mobile_scanner` (バーコードスキャン)
- `barcode_widget`, `pdf`, `printing` (バーコード生成・印刷)
- `audioplayers` (音再生)
- `shared_preferences` (設定保存)

## 5. 開発プロセス

1. **設計確認**: `docs/` 配下の仕様書を必ず参照してから実装を開始してください。
2. **コード生成**: `riverpod_generator` や `isar_generator` を使用する場合、`dart run build_runner build` を実行して最新のコードを生成してください。
3. **テスト**: 重要なロジックについては単体テストを記述してください。

---
このガイドラインは、プロジェクトの成長に合わせて適宜更新されます。
