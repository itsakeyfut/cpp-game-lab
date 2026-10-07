# 決定記録（ADR: Architecture Decision Record）

リポジトリ全体に関わる決定を記録する。題材固有の決定は各題材の `docs/adr/` に置く。

## 運用ルール
- 1 ファイル = 1 つの決定。ファイル名は `NNNN-<内容>.md`（連番）。
- 書いた ADR の「決定」「理由」は書き換えない。方針を変えるときは新しい ADR を追加し、古い ADR の状態を `廃止（ADR-NNNN により）` に変える。
- 状態: `提案中` / `承認` / `廃止（ADR-NNNN により）`
- 新しい ADR は [template.md](template.md) をコピーして書く。

## 一覧
| # | タイトル | 状態 | 日付 |
|---|----------|------|------|
| [0001](0001-record-decisions-as-adr.md) | 決定を ADR として記録する | 承認 | 2026-10-07 |
| [0002](0002-use-raylib-without-engine-or-editor.md) | ゲームエンジン・エディタを使わず raylib を使う | 承認 | 2026-10-06 |
| [0003](0003-functional-core-imperative-shell.md) | Functional Core, Imperative Shell と FP 中心の設計 | 承認 | 2026-10-07 |
| [0004](0004-game-series-and-first-subject.md) | 題材シリーズと最初の題材 | 承認 | 2026-10-06 |
| [0005](0005-monorepo-engine-and-games.md) | モノレポ構成（engine と games） | 承認 | 2026-10-07 |
| [0006](0006-cpp23-and-standard-optional-expected.md) | C++23 と標準の optional / expected | 承認 | 2026-10-06 |
| [0007](0007-toolchain-and-vcpkg.md) | ツールチェーンと依存管理（CMake + Ninja + clang + vcpkg） | 承認 | 2026-10-07 |
| [0008](0008-catch2-for-testing.md) | テストフレームワークに Catch2 v3 を使う | 承認 | 2026-10-07 |
| [0009](0009-no-exceptions.md) | 例外を使わない | 承認 | 2026-10-07 |
| [0010](0010-json-with-glaze.md) | ゲームデータは JSON + glaze | 承認 | 2026-10-07 |
| [0011](0011-naming-conventions.md) | 命名規則 | 承認 | 2026-10-07 |
| [0012](0012-code-quality-tools.md) | コード品質ツール | 承認 | 2026-10-07 |
| [0013](0013-git-workflow-and-ci.md) | Git 運用と CI | 承認（タグは ADR-0018 により廃止） | 2026-10-07 |
| [0014](0014-engine-core-scope.md) | `engine::core` の範囲 | 承認 | 2026-10-07 |
| [0015](0015-public-repo-issues-and-labels.md) | 公開範囲・Issue と PR の流れ・ラベルの体系 | 承認 | 2026-10-07 |
| [0016](0016-utf8-code-page-on-windows.md) | Windows の実行ファイルは UTF-8 のコードページで動かす | 承認 | 2026-10-07 |
| [0017](0017-run-asan-in-ci.md) | CI で AddressSanitizer を常に実行する | 承認 | 2026-10-07 |
| [0018](0018-no-tags-or-versions.md) | タグとバージョン番号を使わない | 承認 | 2026-10-07 |
