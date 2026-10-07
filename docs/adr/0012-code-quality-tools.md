# ADR-0012: コード品質ツール

- 状態: 承認
- 日付: 2026-10-07

## 背景
整形・静的解析・警告・メモリ検査を、立ち上げ時点から仕組みとして組み込みたい。

## 決定
| ツール | 設定 | 目的 |
|--------|------|------|
| clang-format | Microsoft スタイル基準（Allman 形式の中括弧、インデント 4 スペース、1 行 120 文字） | 整形の議論をなくす。中括弧の置き方は UE と同じ（UE はインデントにタブを使う点のみ異なる） |
| clang-tidy | `bugprone-*`, `performance-*`, `modernize-*`, `misc-const-correctness`, `readability-identifier-naming` など。ノイズの多いチェックは個別に無効化 | バグの早期発見と命名規則（[ADR-0011](0011-naming-conventions.md)）の強制 |
| コンパイラ警告 | `-Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wsign-conversion` など | 暗黙の型変換・変数の隠蔽などを検出 |
| 警告をエラー扱い | `ci` プリセットでのみ `-Werror` | 手元の試行錯誤は妨げず、取り込む前には警告ゼロを保証 |
| サニタイザ | `asan` プリセットで AddressSanitizer（可能なら UBSan も） | メモリ破壊・未定義動作の検出 |

- `CMakePresets.json` のプリセット: `debug` / `release` / `asan` / `ci`（`ci` は `-Werror` + clang-tidy 有効）。
- 外部ライブラリのヘッダは `SYSTEM` インクルード扱いにし、警告を出さない。

## 結果
- Windows + clang での AddressSanitizer・UBSan の対応範囲は、立ち上げ時（arena M0）に確認する。
- 確認結果（arena M0, 2026-10-07）: `asan` プリセットは Windows（clang 20）と Linux（clang 20）で動作する。Windows では、MSVC の標準ライブラリの ASan 用注釈を無効にし（`_DISABLE_STL_ANNOTATION`）、ASan の実行時ライブラリを実行ファイルの隣にコピーする必要があった。CI で常に実行する（[ADR-0017](0017-run-asan-in-ci.md)）。UBSan は未確認。
