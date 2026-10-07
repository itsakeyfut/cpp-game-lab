# ADR-0017: CI で AddressSanitizer を常に実行する

- 状態: 承認
- 日付: 2026-10-07

## 背景
- [ADR-0012](0012-code-quality-tools.md) で `asan` プリセットを用意し、Windows と Linux での対応範囲を立ち上げ時に確認することにしていた。
- [ADR-0013](0013-git-workflow-and-ci.md) の CI は `ci` プリセット（警告をエラー扱い + clang-tidy）のみで、サニタイザは手元で必要なときに実行する想定だった。
- 立ち上げ時の確認で、Windows でも次の 2 点を補えば `asan` プリセットが動くことが分かった。
  - MSVC の標準ライブラリは ASan 有効時にコンテナへ注釈を付け、リンク時に注釈の有無を照合する。vcpkg の依存ライブラリは ASan なしでビルドされるため一致せず、リンクできない（`/failifmismatch: annotate_string` など）。
  - ASan の実行時ライブラリが DLL で、実行ファイルから見つからない（`0xc0000135`）。

## 決定
- CI のビルドとテストを「OS（Windows / Linux）× プリセット（`ci` / `asan`）」で実行し、AddressSanitizer を PR ごとに常に実行する。
- Windows で `asan` プリセットを動かすため、`cmake/ProjectOptions.cmake` で次を行う。
  - `_DISABLE_STL_ANNOTATION` を定義し、標準ライブラリの ASan 用注釈を無効にする（自分のコードと依存ライブラリで注釈の有無を揃える）。
  - `cgl_copy_asan_runtime(<target>)` で、ASan の実行時ライブラリを実行ファイルの隣にコピーする。`cgl_configure_target` / `cgl_configure_test_target` から呼ぶ。
- vcpkg のバイナリキャッシュは両プリセットで共有する（依存ライブラリのビルドにはプリセットの設定が影響しないため）。

## 検討した選択肢
| 選択肢 | 長所 | 短所 |
|--------|------|------|
| **CI で常に実行する（Windows + Linux）** | メモリ破壊が PR の時点で見つかる。サニタイザを CI で回すのは業界で一般的。Windows 固有の問題も検出できる | CI のジョブが 2 つ増え、時間がかかる |
| CI で Linux のみ実行する | ASan の実績が多く、設定が単純 | Windows（MSVC 標準ライブラリ）固有の問題を検出できない |
| 立ち上げ時に 1 回だけ確認し、以後は手元で必要なときに実行する | CI の時間が増えない | 実行し忘れると、メモリ破壊を長く見逃す |

## 結果
- Windows の `asan` ビルドでは標準ライブラリの注釈による検出（コンテナの確保済み・未使用領域へのアクセス）が効かない。ヒープの範囲外アクセスなど、それ以外の検出は効く（立ち上げ時に `heap-buffer-overflow` の検出を確認）。注釈も効かせたい場合は、依存ライブラリも ASan 付きでビルドする必要がある。
- UBSan は未確認。必要になったら新しい ADR で扱う。
- UE との対応: UE も ASan 版のビルド構成を持ち、自動テストで実行できる。

## 関連
- [ADR-0012](0012-code-quality-tools.md)、[ADR-0013](0013-git-workflow-and-ci.md)
