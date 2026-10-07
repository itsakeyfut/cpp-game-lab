# ADR-0002: sim の状態・入力・処理パイプラインの形

- 状態: 承認
- 日付: 2026-10-07

## 背景
[ADR-0003（全体）](../../../../docs/adr/0003-functional-core-imperative-shell.md) の方針を、アリーナ・サバイバルの sim で具体的な型と関数の形に落とす必要があった。詳細な定義は [design.md](../design.md) を参照。

## 決定

### 状態: 画面状態ごとに持つデータを変える
```cpp
using GameState = std::variant<TitlePhase, PlayingPhase, GameOverPhase>;
```
`World`（プレイヤー・敵・弾・アイテム・ウェーブ・スコア・乱数）は `PlayingPhase` / `GameOverPhase` だけが持つ。

### 入力: 1 ステップ分のスナップショット
```cpp
struct InputFrame { Vec2 move; Vec2 aimTarget; bool fire; bool confirm; };
```

### 設定: `GameConfig` を引数で渡す
M4 まではコード内の `DefaultConfig()` が返し、M5 で JSON から読むように差し替える。

### 処理: 純粋関数のパイプライン
```cpp
StepResult Step(const GameConfig& config, GameState state, const InputFrame& input, float dt);
```
プレイ中は 10 段階（ApplyPlayerInput → RunEnemyAi → FireWeapons → Integrate → TickTimers → DetectCollisions → ResolveContacts → DropPickups → RemoveExpired → UpdateWave）を、Writer モナドの簡易版 `Staged { World world; std::vector<Event> events; }` と `|` でつなぐ。段階同士は中間データ（`Contact` 一覧）とイベントで受け渡す。

### app: 描画も純粋な部分と副作用に分ける
`ReadRawInput`（副作用）→ `MakeInputFrame` → `Step` → `UpdateFx` → `BuildDrawList`（ここまで純粋）→ `Submit`（副作用）。

## 検討した選択肢
| 論点 | 採用 | 不採用 | 理由 |
|------|------|--------|------|
| 状態の表し方 | 画面状態ごとの `std::variant` | 1 つの struct + `enum Phase` | 「タイトル画面なのにプレイヤーの HP がある」のような、ありえない状態を型で作れなくする |
| 入力の表し方 | 1 ステップ分のスナップショット `InputFrame` | Command（「右へ移動」「射撃」）の配列 | `InputFrame` の列を保存するだけでリプレイができる。固定タイムステップのゲームで一般的 |
| 選択肢の表し方（敵の行動・アイテム効果・イベント） | `std::variant` + `std::visit` | 継承 + 仮想関数 | 選択肢を増やしたときの処理漏れをコンパイラが検出する。値型のまま扱える |
| 段階のつなぎ方 | `Staged` と `|` | 段階を順に呼んでイベントを手で連結 | 同じ形の関数を並べるだけになり、順序の入れ替え・追加が容易 |
| `Staged` の置き場所 | まず `arena::sim` | 最初から `engine` | 共有が必要になった時点で移す（[ADR-0005](../../../../docs/adr/0005-monorepo-engine-and-games.md)） |
| 描画 | `BuildDrawList`（純粋）+ `Submit`（副作用） | 状態を見ながら直接 raylib を呼ぶ | 何を描くかをテストでき、raylib に触れる箇所が集まる（UE の Scene Proxy と同じ考え方） |

## 結果
- sim は描画なしで実行・テストできる（シナリオテスト・決定論テスト）。
- UE との対応は [ue-mapping.md](../../../../docs/ue-mapping.md) を参照。
