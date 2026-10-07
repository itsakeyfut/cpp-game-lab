# コーディング規約

リポジトリ全体（`engine/` と全題材）に適用する。決定の経緯は [adr/](adr/README.md) を参照。

---

## 1. 命名

[ADR-0011](adr/0011-naming-conventions.md)

| 対象 | 規則 | 例 |
|------|------|----|
| 型（struct / class / enum / alias） | PascalCase | `EnemyDef`, `WorldState` |
| 関数 | PascalCase | `StepWorld()`, `ApplyDamage()` |
| ローカル変数・引数 | camelCase | `deltaTime`, `enemyCount` |
| struct のメンバ | camelCase（接頭辞なし） | `health.current` |
| class の private メンバ | camelCase + 末尾 `_` | `capacity_` |
| bool | `is` / `has` / `can` で始める | `isAlive`, `hasTarget` |
| 定数・constexpr 変数 | `k` + PascalCase | `kMaxEnemies` |
| enum の値 | PascalCase（`enum class` のみ使用） | `Faction::Player` |
| 名前空間 | 小文字 | `engine::core`, `arena::sim` |
| ファイル名 | snake_case | `world_state.hpp`, `world_state.cpp` |
| マクロ | 大文字 + モジュール接頭辞 | `ENGINE_ASSERT` |
| テンプレート引数 | PascalCase | `template <class T>`, `template <class Tag>` |

UE の型接頭辞（`F` / `U` / `A` / `E` / `T`）や bool の `b` は付けない。

## 2. ファイル
- ヘッダは `.hpp`、実装は `.cpp`。
- ヘッダの先頭は `#pragma once`。
- 公開ヘッダは `include/<名前空間>/<module>/` に置き、`#include <engine/core/error.hpp>` の形で参照する。
- モジュール内部でのみ使うヘッダは `src/` に置く。
- インクルード順（clang-format で自動整列）: 対応するヘッダ → 同じリポジトリのヘッダ → 外部ライブラリ → 標準ライブラリ。

## 3. 整形・静的解析

[ADR-0012](adr/0012-code-quality-tools.md)
- 整形は `.clang-format` に従う（Microsoft 基準・Allman・4 スペース・120 桁）。手で整形しない。
- `.clang-tidy` の警告はすべて解消する。抑制する場合は `// NOLINT(<check名>): <理由>` で理由を書く。
- `ci` プリセットでは警告をエラーとして扱う。

## 4. 設計の原則

### 4.1 合成を優先し、継承を避ける

[ADR-0003](adr/0003-functional-core-imperative-shell.md)
- データは小さな部品 struct を集約して表す（`struct Enemy { Kinematics kinematics; Health health; ... };`）。
- 「決まった選択肢のどれか 1 つ」は `std::variant` で表し、`std::visit` で分岐する。仮想関数による多態は使わない。
- 継承を使ってよいのは、外部ライブラリが要求する場合のみ。使う場合は理由をコメントに書く。

### 4.2 純粋関数を中心にする

[ADR-0003](adr/0003-functional-core-imperative-shell.md)
- ゲームのルールは自由関数（メンバ関数ではない関数）として書き、引数だけから結果を決める。グローバル変数・静的な可変状態は使わない。
- 状態を更新する関数は「値で受けて新しい値を返す」: `World Integrate(World world, float dt);` 呼び出し側は `std::move` で渡す。
- 読むだけの引数は `const T&`、小さな値型（`Vec2`、ID、数値）は値渡し。
- 乱数生成器も値として受け渡す（`Next(Rng) -> std::pair<値, Rng>`）。
- 副作用（入力・描画・ファイル・時刻・ログ）は app と content の入口に限定する。
- ループで値を集める処理は、可能なら `std::ranges` のアルゴリズムで書く。読みやすさが落ちる場合は素直な `for` でよい。

### 4.3 データ型
- データは public メンバのみの struct（集約型）にし、指示付き初期化子で作る: `Health{.current = 10, .max = 10}`。
- 不変条件を守る必要がある型だけ class にし、メンバを private にする。
- 異なる意味の ID は `StrongId<Tag>` で型を分ける。
- `enum class` のみ使う（素の `enum` は使わない）。

### 4.4 メモリと資源
- `new` / `delete` を直接書かない。所有は値・`std::vector`・`std::unique_ptr` で表す。
- 外部ライブラリの資源（ウィンドウ等）は RAII の小さな型で包む。
- 生ポインタは「所有しない・null になりうる参照」の場合のみ。null にならないなら参照を使う。

### 4.5 const と属性
- 変更しない変数は `const` にする（clang-tidy `misc-const-correctness` で検査）。
- 戻り値を無視してはいけない関数（`Result` / `optional` を返す関数、新しい状態を返す関数）には `[[nodiscard]]` を付ける。
- 定数は `constexpr`、コンパイル時に計算できる関数は `constexpr` にする。

## 5. エラー処理

詳細は [error-handling.md](error-handling.md)。例外（`throw` / `try`）は使わない。

## 6. テスト

[ADR-0008](adr/0008-catch2-for-testing.md)
- テストは各モジュールの `tests/` に置き、ファイル名は `<対象>_test.cpp`。
- Catch2 v3 を使う。`TEST_CASE` 名は「対象: 期待する振る舞い」の形で書く（例: `"ApplyDamage: HP は 0 未満にならない"`）。
- テストの実行ファイルは `cgl_configure_test_target` で設定する。Windows では UTF-8 コードページで動くため、日本語のテスト名を CTest で個別に実行できる（[ADR-0016](adr/0016-utf8-code-page-on-windows.md)）。
- sim の機能はテストを先に書く。
