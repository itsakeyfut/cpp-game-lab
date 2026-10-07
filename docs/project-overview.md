# プロジェクト概要 — cpp-game-lab

## 1. 目的

### 1.1 作るもの
C++ で、Unreal Engine などのゲームエンジンを使わずにゲームモデルを定義し、簡単なゲームを作る。題材ごとに 1 本ずつゲームを作り、このリポジトリに積み上げていく（[ADR-0004](adr/0004-game-series-and-first-subject.md), [ADR-0005](adr/0005-monorepo-engine-and-games.md)）。

### 1.2 学習目標
このリポジトリの変遷を観察し、以下を Unreal Engine でのゲーム開発に活かす。
- C++ プロジェクトの立ち上げから成長までの流れ
- C++ のベストプラクティス（ビルド設定・設定ファイル・ディレクトリ構成を含む）
- C++ での設計
- C++ への FP（関数型プログラミング）スタイルの取り込み
- C++ での Result / Option 型の扱い方

そのため、**変遷が追えること**（コミット履歴と決定記録が読める状態）自体を成果物の一部とみなす。

## 2. 設計の原則
| 原則 | 内容 | 詳細 |
|------|------|------|
| 実務のベストプラクティスに従う | ビルド設定・設定ファイル・ディレクトリ構成は、ゲーム業界の実務で一般的な方法を採る | [repository-structure.md](repository-structure.md) |
| 継承より合成 | 小さな部品の集約と `std::variant` で表し、継承は最小限にする | [ADR-0003](adr/0003-functional-core-imperative-shell.md) |
| 純粋関数・イベント・メッセージング | ゲームのルールは純粋関数。何が起きたかはイベント（値）で伝える | [ADR-0003](adr/0003-functional-core-imperative-shell.md) |
| FP スタイル | 値型・不変な受け渡し・Result / Option によるエラー表現 | [ADR-0006](adr/0006-cpp23-and-standard-optional-expected.md), [error-handling.md](error-handling.md) |
| エディタを使わない | すべてコードで構築する | [ADR-0002](adr/0002-use-raylib-without-engine-or-editor.md) |

## 3. 技術スタック
| 項目 | 選択 | 決定記録 |
|------|------|----------|
| 言語 | C++23 | [ADR-0006](adr/0006-cpp23-and-standard-optional-expected.md) |
| コンパイラ | clang / clang++ | [ADR-0007](adr/0007-toolchain-and-vcpkg.md) |
| ビルド | CMake + Ninja（`CMakePresets.json`） | [ADR-0007](adr/0007-toolchain-and-vcpkg.md) |
| 依存管理 | vcpkg マニフェストモード | [ADR-0007](adr/0007-toolchain-and-vcpkg.md) |
| 描画・入力 | raylib | [ADR-0002](adr/0002-use-raylib-without-engine-or-editor.md) |
| テスト | Catch2 v3 | [ADR-0008](adr/0008-catch2-for-testing.md) |
| ゲームデータ | JSON + glaze | [ADR-0010](adr/0010-json-with-glaze.md) |
| 品質 | clang-format / clang-tidy / 厳しめの警告 / AddressSanitizer | [ADR-0012](adr/0012-code-quality-tools.md) |
| VCS・CI | GitHub / GitHub Actions（Windows + Linux） | [ADR-0013](adr/0013-git-workflow-and-ci.md) |

## 4. 題材シリーズ
各題材は「主に学ぶテーマ」を 1 つ持ち、関心が重ならないようにする。順番は予定であり、各題材の開始時に見直す（[ADR-0004](adr/0004-game-series-and-first-subject.md)）。

| # | 題材 | ディレクトリ | 主な学習テーマ | UE での対応物 | 状態 |
|---|------|--------------|---------------|--------------|------|
| 1 | アリーナ・サバイバル（3D 見下ろし型ツインスティック・シューター） | `games/arena-survival` | 土台一式: 立ち上げ、ゲームループと固定タイムステップ、合成、イベント、Result / Option、設定ファイル | `UWorld` / `Tick`、Actor + Component、Delegate、GameMode、DataAsset | 設計済み |
| 2 | 3D グリッドパズル（倉庫番風） | 未定 | 不変データと状態遷移、Undo / Redo、リプレイ、決定論的テスト、レベルデータのパース | Command パターン、シリアライズ、Automation Test | 予定 |
| 3 | タワーディフェンス | 未定 | データ駆動設計、純粋関数としての経路探索、ステートマシン、UI と経済 | DataTable、Navigation、UMG、StateTree | 予定 |
| 4 | 物理アクション（プラットフォーマー） | 未定 | 数値積分、衝突検出と解決、キャラクター制御、決定論 | Chaos、`UCharacterMovementComponent` | 予定 |
| 5 | ターン制タクティクス（SRPG） | 未定 | アビリティ / エフェクトのデータ設計、アクションキュー、AI の探索 | Gameplay Ability System、Gameplay Tag | 予定 |
| 6 | コロニー / RTS ライト | 未定 | 大量エンティティ、データ指向設計（ECS）、並列処理、Utility AI / Behavior Tree | Mass Entity、Behavior Tree、Task Graph | 予定 |
