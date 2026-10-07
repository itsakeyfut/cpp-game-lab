# ADR-0014: `engine::core` の範囲

- 状態: 承認
- 日付: 2026-10-07

## 背景
全題材で共有する土台モジュール `engine/core` に何を置くかを決める必要があった。置きすぎると推測による共通化になり、少なすぎると各題材で同じものを作ることになる。

## 決定
最初は次の 5 つだけを置く。すべて副作用のない値型と純粋関数。

| ファイル | 内容 | UE での対応 |
|----------|------|-------------|
| `error.hpp` | `Error`（メッセージ・文脈・発生場所）、`Result<T> = std::expected<T, Error>`、文脈を追記する `WithContext` | `TValueOrError` |
| `assert.hpp` | `ENGINE_ASSERT(cond, msg)` | `check()` / `checkf()` |
| `math.hpp` | 自作の `Vec2` と演算。`Normalize(Vec2) -> std::optional<Vec2>` | `FVector2D`、`GetSafeNormal()` |
| `random.hpp` | 値として受け渡す決定論的乱数 `Rng`（PCG32）。`Next(Rng) -> {値, 次の Rng}` | `FRandomStream` |
| `strong_id.hpp` | 取り違えを防ぐ型付き ID `StrongId<Tag>` | 型付きハンドル |

方針:
- エラー型は汎用の `Error` 1 種類から始める。呼び出し側が種類で分岐する必要が出たら、そのモジュールに専用の `enum class` を追加する。
- ログ出力は副作用なので置かない。
- その他の共有部品（パイプラインをつなぐ `Staged` など）は、2 本目の題材で必要になった時点で題材側から移す（[ADR-0005](0005-monorepo-engine-and-games.md)）。

## 検討した選択肢（数学）
| 選択肢 | 長所 | 短所 |
|--------|------|------|
| **自作の最小限の `Vec2`** | 必要なのは数個の関数だけ。sim を外部ライブラリに依存させない | 必要に応じて自分で追加する |
| glm | 業界で広く使われ、機能が豊富 | この規模では過剰。sim が外部ライブラリに依存する |
| raylib の `Vector2` / `Vector3` | 追加不要 | sim が描画ライブラリに依存し、[ADR-0003](0003-functional-core-imperative-shell.md) に反する |

## 結果
- 2D の題材（アリーナ）はゲームを平面上で計算し、描画時に 3D へ持ち上げる。高さが必要な題材が来たら `Vec3` を追加する。
