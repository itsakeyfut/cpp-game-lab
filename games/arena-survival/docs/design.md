# Arena Survival — 設計書

題材シリーズ #1。決定の経緯と理由は、この題材の決定記録 [adr/](adr/README.md) とリポジトリ全体の決定記録 [docs/adr/](../../../docs/adr/README.md) を参照。

---

## 1. 概要

3D 見下ろし型のツインスティック・シューター。プレイヤーは平面のアリーナを移動して射撃し、ウェーブごとに出現する敵を倒す。被弾で HP が減り、0 でゲームオーバー。スコアを競う。

### 1.1 この題材で主に学ぶこと
プロジェクトの土台一式: 立ち上げ手順、ゲームループと固定タイムステップ、合成、イベント / メッセージング、Result / Option、設定ファイルの読み込み（[ADR-0004](../../../docs/adr/0004-game-series-and-first-subject.md)）。

### 1.2 ゲーム仕様（v1.0 の範囲）
| 項目 | 仕様 |
|------|------|
| 視点 | 斜め上からの固定カメラ。アリーナ全体が見える |
| 操作 | WASD で移動、マウスで照準、左クリックで射撃、決定キーで開始・リスタート |
| プレイヤー | HP あり。敵・敵弾に接触するとダメージを受け、一定時間無敵になる。HP 0 でゲームオーバー |
| 敵 | 突撃型（プレイヤーへ直進）、射撃型（距離を取って弾を撃つ） |
| ウェーブ | 敵が全滅すると次のウェーブ。数と種類が増えていく |
| アイテム | 敵が確率でドロップ。回復、連射速度アップ。一定時間で消える |
| スコア | 撃破で加算。ゲームオーバー画面に表示 |
| 画面 | タイトル → プレイ中 → ゲームオーバー → プレイ中（リスタート） |

範囲外: サウンド素材、3D モデル、セーブ、ネットワーク、メニューの作り込み。

### 1.3 描画
キューブ・球・平面などの単純な形のみ。アセットは作らない。

---

## 2. アーキテクチャ全体

[ADR-0003](../../../docs/adr/0003-functional-core-imperative-shell.md)

Functional Core, Imperative Shell。ゲームのルールはすべて純粋関数（sim）に置き、副作用（入力・描画・ファイル）は外側（app / content の入口）に集める。

```
          ┌──────────── app（副作用: raylib）─────────────┐
キー入力 ─▶│ ReadRawInput → MakeInputFrame                  │
          │                   │ InputFrame                 │
          │                   ▼                            │
          │   sim::Step(config, state, input, dt)  純粋関数 │
          │         → StepResult { state, events }         │
          │                   │                            │
          │   UpdateFx(fx, events) → BuildDrawList → Submit │
          └────────────────────────────────────────────────┘
```

性質:
- `Step` は決定論的。同じ `GameConfig`・状態・入力列・乱数の種なら必ず同じ結果になる（乱数も状態の一部）。
- `Step` は固定タイムステップ（1/60 秒）で呼ぶ。描画は可変フレームレート。

---

## 3. モジュール構成と依存

[ADR-0005](../../../docs/adr/0005-monorepo-engine-and-games.md)、[repository-structure.md](../../../docs/repository-structure.md)

| ディレクトリ | CMake ターゲット | 名前空間 | 責務 | 依存 |
|--------------|------------------|----------|------|------|
| `engine/core` | `engine_core` | `engine::core` | 全題材で共有する土台（エラー型・アサート・数学・乱数・ID） | なし |
| `games/arena-survival/sim` | `arena_sim` | `arena::sim` | ゲームモデル（状態・ルール・イベント）。純粋関数のみ。raylib に依存しない | `engine_core` |
| `games/arena-survival/content` | `arena_content` | `arena::content` | JSON から `GameConfig` を作る（M5 から） | `arena_sim`, `engine_core`, glaze |
| `games/arena-survival/app` | `arena_app`（実行ファイル） | `arena::app` | 入力・描画・メインループ | 上記すべて, raylib |

依存は `app → content → sim → engine/core` の一方向のみ。`engine` から `games` への依存、題材同士の依存は禁止。

各ライブラリモジュールの内部構成:
```
<module>/
├── CMakeLists.txt
├── include/<名前空間>/<module>/   公開ヘッダ（UE の Public/）
├── src/                           実装（UE の Private/）
└── tests/                         このモジュールのテスト
```

---

## 4. `engine::core`

[ADR-0014](../../../docs/adr/0014-engine-core-scope.md)

| ファイル | 内容 |
|----------|------|
| `error.hpp` | `struct Error { std::string message; std::vector<std::string> context; std::source_location location; };`<br>`template <class T> using Result = std::expected<T, Error>;`<br>`WithContext(std::string)`: 失敗時に文脈を追記する（`result.transform_error(WithContext("..."))`） |
| `assert.hpp` | `ENGINE_ASSERT(cond, msg)`: 失敗時に場所とメッセージを出力し停止。デバッガ接続時はブレーク |
| `math.hpp` | `struct Vec2 { float x, y; }` と constexpr の演算子、`Length`, `Dot`、`Normalize(Vec2) -> std::optional<Vec2>`（長さ 0 なら `nullopt`） |
| `random.hpp` | `struct Rng { std::uint64_t state; }`（PCG32）。`Next(Rng) -> std::pair<std::uint32_t, Rng>`、範囲指定の `NextFloat` など。乱数生成器も値として受け渡す |
| `strong_id.hpp` | `template <class Tag> struct StrongId { std::uint32_t value; };` と比較演算子 |

- sim は 2D（XZ 平面）で計算し、app が描画時に 3D へ持ち上げる。
- ログ出力は置かない（副作用のため。sim は events で外に知らせる）。
- 外部の数学ライブラリは使わない。

---

## 5. `arena::sim` のデータモデル

[arena ADR-0001](adr/0001-entity-representation-value-arrays.md)、[arena ADR-0002](adr/0002-sim-state-input-and-pipeline.md)

### 5.1 部品
| 部品 | フィールド |
|------|------------|
| `Kinematics` | `Vec2 position`, `Vec2 velocity` |
| `Collider` | `float radius`（当たり判定は円） |
| `Health` | `int current`, `int max` |
| `Invulnerability` | `float remaining` |
| `Weapon` | `float fireInterval`, `float cooldown`, `int damage`, `float projectileSpeed` |
| `Lifetime` | `float remaining` |

部品ごとに純粋関数を書く（例: `ApplyDamage(Health, int) -> Health`、`Tick(Lifetime, float) -> Lifetime`）。

### 5.2 種類
```cpp
struct Player     { Kinematics kinematics; Collider collider; Health health; Invulnerability invulnerability; Weapon weapon; Vec2 aim; };
struct Enemy      { EnemyId id; Kinematics kinematics; Collider collider; Health health; Behavior behavior; int scoreValue; };
struct Projectile { ProjectileId id; Faction owner; Kinematics kinematics; Collider collider; Lifetime lifetime; int damage; };
struct Pickup     { PickupId id; Kinematics kinematics; Collider collider; Lifetime lifetime; PickupEffect effect; };

struct ChaseAi   { float speed; };
struct ShooterAi { float speed; float preferredDistance; Weapon weapon; };
using Behavior = std::variant<ChaseAi, ShooterAi>;

struct Heal       { int amount; };
struct FireRateUp { float multiplier; };
using PickupEffect = std::variant<Heal, FireRateUp>;

enum class Faction { Player, Enemy };
```
- 決まった選択肢のどれか 1 つは、継承ではなく `std::variant` で表し `std::visit` で分岐する。
- 弾・アイテムも含めすべて `std::vector` に値で保持する（[arena ADR-0001](adr/0001-entity-representation-value-arrays.md)）。

### 5.3 ゲーム全体の状態
```cpp
struct WaveState { int number; int remainingToSpawn; float spawnTimer; };
struct IdCounters { std::uint32_t enemy; std::uint32_t projectile; std::uint32_t pickup; };

struct World {
    Player player;
    std::vector<Enemy> enemies;
    std::vector<Projectile> projectiles;
    std::vector<Pickup> pickups;
    WaveState wave;
    int score;
    Rng rng;
    IdCounters ids;
};

struct TitlePhase    { Rng rng; };
struct PlayingPhase  { World world; };
struct GameOverPhase { World finalWorld; };
using GameState = std::variant<TitlePhase, PlayingPhase, GameOverPhase>;

GameState MakeInitialState(std::uint64_t seed);
```
ありえない状態（タイトル画面にプレイヤーの HP がある等）を型で作れないようにする。

### 5.4 入力・設定・イベント
```cpp
struct InputFrame { Vec2 move; Vec2 aimTarget; bool fire; bool confirm; };

struct GameConfig { PlayerDef player; std::vector<EnemyDef> enemies; std::vector<WaveDef> waves; ArenaDef arena; };
GameConfig DefaultConfig();   // M0〜M4 はコード内の値。M5 で content から読み込む

using Event = std::variant<PlayerDamaged, PlayerDied, EnemySpawned, EnemyKilled, ProjectileFired,
                           PickupSpawned, PickupCollected, WaveStarted, WaveCleared, PhaseChanged>;

struct StepResult { GameState state; std::vector<Event> events; };
StepResult Step(const GameConfig& config, GameState state, const InputFrame& input, float dt);
```
- 入力は 1 ステップ分のスナップショット。`InputFrame` の列を保存すればリプレイになる。
- `GameState` は値で受け取り、呼び出し側はムーブで渡す（コピーを発生させない）。
- 各イベントは発生位置・対象 ID など、app が演出に必要な情報を持つ。

---

## 6. `Step` の処理

[arena ADR-0002](adr/0002-sim-state-input-and-pipeline.md)

### 6.1 画面状態の切り替え
`Step` は `std::visit` で `GameState` を分岐する。

| 現在 | 条件 | 次 |
|------|------|----|
| `TitlePhase` | `input.confirm` | `PlayingPhase`（`NewWorld(config, rng)`） |
| `PlayingPhase` | プレイヤーの HP が 0 | `GameOverPhase` |
| `GameOverPhase` | `input.confirm` | `PlayingPhase`（`finalWorld.rng` を引き継いで新しいワールド） |

切り替え時に `PhaseChanged` を出す。

### 6.2 プレイ中のパイプライン
| 順 | 段階 | 内容 | イベント |
|----|------|------|----------|
| 1 | `ApplyPlayerInput` | 入力からプレイヤーの速度・照準 | — |
| 2 | `RunEnemyAi` | `Behavior` を `std::visit` して敵の速度を決める | — |
| 3 | `FireWeapons` | クールダウンが 0 の武器から弾を生成 | `ProjectileFired` |
| 4 | `Integrate` | 位置 += 速度 × dt、アリーナ内に制限 | — |
| 5 | `TickTimers` | クールダウン・無敵時間・寿命を減らす | — |
| 6 | `DetectCollisions` | 状態を読み、`std::vector<Contact>` を返す | — |
| 7 | `ResolveContacts` | ダメージ・アイテム取得を適用 | `PlayerDamaged`, `PlayerDied`, `EnemyKilled`, `PickupCollected` |
| 8 | `DropPickups` | `EnemyKilled` を受けて確率でアイテム生成 | `PickupSpawned` |
| 9 | `RemoveExpired` | HP 0・寿命切れ・命中済みを `std::erase_if` で除去 | — |
| 10 | `UpdateWave` | 敵の出現、ウェーブ終了・開始 | `EnemySpawned`, `WaveCleared`, `WaveStarted` |

ルール:
- 各段階は `World` を値で受け、新しい `World` とイベントを返す純粋関数。段階単位でテストする。
- 段階同士は中間データ（`Contact` 一覧）とイベントで受け渡す。段階が別の段階を直接呼ばない。
- 段階は次の `Staged` と `|` でつなぐ（Writer モナドの簡易版）。sim 内に置き、2 本目の題材で共有が必要になったら `engine` へ移す。

```cpp
struct Staged { World world; std::vector<Event> events; };

auto result = Begin(std::move(world))
            | ApplyPlayerInput(input)
            | RunEnemyAi(config)
            | FireWeapons(config)
            | Integrate(config, dt)
            | TickTimers(dt)
            | ResolveCollisions()          // DetectCollisions + ResolveContacts
            | DropPickups(config)
            | RemoveExpired()
            | UpdateWave(config, dt);
```
段階 6 と 7 は、`DetectCollisions` が `World` ではなく `Contact` 一覧を返すため、パイプ上では `ResolveCollisions`（内部で `DetectCollisions` → `ResolveContacts` を呼ぶ）としてまとめてつなぐ。単体テストは 6 と 7 を別々に行う。

### 6.3 当たり判定
M3〜M6 は総当たり。M7 でベンチマークに基づき一様グリッドによる空間分割を導入する。

---

## 7. app

[arena ADR-0002](adr/0002-sim-state-input-and-pipeline.md)

```
初期化: Window（RAII）→ GameConfig 取得 → MakeInitialState(seed)
ループ:
  1. ReadRawInput()               副作用: raylib からキー・マウス
  2. MakeInputFrame(raw, camera)  純粋: マウス座標 → アリーナ平面座標 など
  3. accumulator >= dt の間 Step  純粋
  4. UpdateFx(fx, events, dt)     純粋: 見た目専用の状態（被弾の点滅・撃破の破片）
  5. BuildDrawList(state, fx)     純粋: std::vector<DrawCommand>
  6. Submit(drawList)             副作用: raylib で描画
```
- raylib を呼ぶのは `ReadRawInput` と `Submit`（と初期化）のみ。
- ゲームのルールに影響しない状態（`FxState`）は sim に入れない。

---

## 8. content（M5）

[ADR-0010](../../../docs/adr/0010-json-with-glaze.md)

```cpp
Result<GameConfig> LoadGameConfig(const std::filesystem::path& dir);   // 副作用: ファイルを読み ParseGameConfig へ
Result<GameConfig> ParseGameConfig(std::string_view json);             // 純粋: glaze で DTO → 検証 → GameConfig
```
- 流れ: `ファイル読み込み → DTO 構造体（glaze）→ 検証してドメイン型へ`。すべて `std::expected` でつなぐ。
- 検証は全項目を確認し、エラーをまとめて返す（`std::vector<Result<T>>` → `Result<std::vector<T>>`）。
- app は読み込みに失敗したらエラー（文脈付き）を表示し、終了コード 1 で終了する。
- データファイルは `games/arena-survival/data/` に置く。

---

## 9. エラー処理

[ADR-0009](../../../docs/adr/0009-no-exceptions.md)
詳細は [error-handling.md](../../../docs/error-handling.md)。
- 想定内の失敗 → `Result<T>`
- 値がないことが正常 → `std::optional<T>`
- バグ → `ENGINE_ASSERT`
- 例外は使わない（`engine_core` / `arena_sim` / `arena_content` / `arena_app` は `-fno-exceptions`。テストのみ有効）。

---

## 10. テスト

[ADR-0008](../../../docs/adr/0008-catch2-for-testing.md)

| 種類 | 対象 | 内容 |
|------|------|------|
| 単体 | `engine::core`、sim の各段階、content | 入力 → 出力の検証。sim はテストを先に書く |
| シナリオ | sim 全体 | 決めた `InputFrame` 列で `Step` を N 回呼び、状態とイベントを検証 |
| 決定論 | sim 全体 | 同じ種・同じ入力列で 2 回実行し、結果が完全一致 |
| 異常系 | content | 壊れた JSON・範囲外の値・必須項目なし → 期待どおりのエラー |
| ベンチマーク | sim（M7） | Catch2 `BENCHMARK`。性能目標を CI で確認 |
| app | 純粋関数のみ | `MakeInputFrame`・`BuildDrawList`・`UpdateFx`。raylib 部分は手動確認 |

---

## 11. 性能目標

[arena ADR-0001](adr/0001-entity-representation-value-arrays.md)
弾 10,000 + 敵 500 + アイテム 1,000 の状態で、`Step` 1 回が 2ms 以内（clang, release）。目標を割った場合は計測結果をもとに格納方式（SoA / ECS）を検討する。

---

## 12. マイルストーン

[arena ADR-0003](adr/0003-milestones-and-late-data-driven.md)、[ADR-0018](../../../docs/adr/0018-no-tags-or-versions.md)

マイルストーンごとに親 Issue を作って管理する（タグは付けない）。

| # | 内容 |
|---|------|
| M0 | 立ち上げ: CMake / プリセット / vcpkg / 品質ツール / CI / `engine::core` / raylib の空ウィンドウ / テスト 1 本 |
| M1 | プレイヤーが動く: `Step` / `InputFrame` / 固定タイムステップ / 描画 |
| M2 | 射撃と弾 |
| M3 | 突撃型の敵・当たり判定・HP・撃破・スコア |
| M4 | ウェーブ・タイトル / ゲームオーバー / リスタート |
| M5 | データ駆動化（JSON → `GameConfig`） |
| M6 | 射撃型の敵・アイテム |
| M7 | ベンチマーク・空間グリッド |

各マイルストーンで設計書と実装がずれた場合は本書を更新し、重要な変更は新しい ADR として記録する。
