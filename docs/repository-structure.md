# リポジトリ構成

決定の理由は [ADR-0005](adr/0005-monorepo-engine-and-games.md) を参照。

## 1. ディレクトリ構成
```
cpp-game-lab/
├── CMakeLists.txt              # 最上位: project()、共通設定、add_subdirectory のみ
├── CMakePresets.json           # debug / release / asan / ci
├── vcpkg.json                  # 依存ライブラリの宣言
├── vcpkg-configuration.json    # vcpkg のバージョン基準（baseline）
├── .clang-format               # 自動整形ルール
├── .clang-tidy                 # 静的解析ルール
├── .editorconfig               # 改行・インデント・文字コード
├── .gitignore / .gitattributes
├── README.md                   # ビルド手順
├── cmake/                      # 共通 CMake 関数
│   ├── CompilerWarnings.cmake  #   警告設定
│   └── ProjectOptions.cmake    #   C++23、-fno-exceptions、サニタイザ等
├── docs/                       # リポジトリ全体の文書（本ファイルなど）
│   └── adr/                    #   全体に関わる決定記録
├── engine/                     # 全題材で共有するモジュール（UE の Engine/ に相当）
│   └── core/
└── games/                      # 題材ごとのゲーム（UE のゲームプロジェクトに相当）
    └── arena-survival/
        ├── CMakeLists.txt
        ├── README.md           #   題材の説明・学習テーマ
        ├── docs/               #   設計書・この題材の決定記録
        ├── sim/                #   ゲームモデル（純粋関数、raylib に依存しない）
        ├── content/            #   ゲームデータ読み込み（JSON → sim の型）
        ├── app/                #   raylib の入力・描画・メインループ（実行ファイル）
        └── data/               #   ゲームデータの JSON
```

## 2. モジュール
1 ディレクトリ = 1 CMake ターゲット = UE の 1 モジュール。ライブラリモジュールの内部構成は共通:
```
<module>/
├── CMakeLists.txt
├── include/<名前空間>/<module>/   公開ヘッダ（UE の Public/）
├── src/                           実装・内部ヘッダ（UE の Private/）
└── tests/                         このモジュールのテスト
```
- 依存は `target_link_libraries` で明示し、`PUBLIC` / `PRIVATE` を区別する（UE の `PublicDependencyModuleNames` / `PrivateDependencyModuleNames`）。
- テストはモジュール内に置く（UE もモジュール内に Tests を置く）。

## 3. 依存のルール
```
games/<題材>/app ─▶ content ─▶ sim ─▶ engine/*
games/A  ──✕──▶ games/B      題材同士の依存は禁止
engine/* ──✕──▶ games/*      共有側から題材側への依存は禁止
```
- 依存は一方向のみ。循環させない。
- `engine/` には最初 `core` のみ置く。ゲームループ・イベント基盤・描画補助などは、**2 本目以降の題材で実際に共有が必要になった時点で**題材側から `engine/` へ移す。推測で共通化しない。

## 4. 名前空間とインクルードパス
| 場所 | 名前空間 | インクルード例 |
|------|----------|----------------|
| `engine/<module>` | `engine::<module>` | `#include <engine/core/error.hpp>` |
| `games/<題材>/<module>` | `<題材の短縮名>::<module>` | `#include <arena/sim/world.hpp>` |

題材の短縮名: アリーナ・サバイバル = `arena`。

## 5. 依存ライブラリ
1 つの `vcpkg.json` にまとめる。題材ごとの切り替えが必要になったら vcpkg の features を使う。
