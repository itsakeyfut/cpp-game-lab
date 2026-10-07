# 本プロジェクトの概念と Unreal Engine の対応表

本プロジェクトで学んだ設計を UE で手書きするときの対応表。題材を追加するたびに追記する。

---

## 1. プロジェクト構成

| 本プロジェクト | UE | 補足 |
|----------------|----|------|
| `engine/` | `Engine/` | 全ゲームで共有する部品 |
| `games/<題材>/` | ゲームプロジェクト（`.uproject`） | |
| CMake ターゲット（`engine_core`, `arena_sim`） | モジュール（`.Build.cs`） | |
| `include/<ns>/<module>/` | `Public/` | 他モジュールに公開するヘッダ |
| `src/` | `Private/` | 実装・内部ヘッダ |
| `target_link_libraries(... PUBLIC ...)` | `PublicDependencyModuleNames` | |
| `target_link_libraries(... PRIVATE ...)` | `PrivateDependencyModuleNames` | |
| vcpkg（`vcpkg.json`） | `ThirdParty/` に同梱 + `.Build.cs` | UE は外部ライブラリをソースごと同梱する方式 |
| `CMakePresets.json` の構成 | ビルド構成（Debug / Development / Shipping） | |
| Catch2 のテスト | Low-Level Tests（Catch2 ベース）/ Automation Test | |

## 2. 型

| 本プロジェクト | UE | UE で足りないもの・注意 |
|----------------|----|-------------------------|
| `std::optional<T>` | `TOptional<T>` | `and_then` / `transform` がない → 自由関数で補う（例: `template <class T, class F> auto Transform(const TOptional<T>&, F)`） |
| `engine::core::Result<T>`（`std::expected`） | `TValueOrError<T, E>` | モナド操作がない → `and_then` 相当の自由関数を書くか、早期 return |
| `std::variant` / `std::visit` | `TVariant` / `Visit` | |
| `std::vector` | `TArray` | |
| `std::erase_if(vec, pred)` | `TArray::RemoveAll(pred)` / `RemoveAllSwap` | |
| `std::unique_ptr` | `TUniquePtr` | UObject は GC 管理なので別扱い |
| `std::function` | `TFunction` / Delegate | |
| `std::string` | `FString` / `FName` / `FText` | 用途で使い分ける |
| `Vec2` | `FVector2D` / `FVector` | |
| `Normalize(v) -> optional` | `GetSafeNormal()` | UE は長さ 0 のとき 0 ベクトルを返す |
| `Rng`（値として受け渡す乱数） | `FRandomStream` | |
| `StrongId<Tag>` | 型付きハンドル / `FGuid` | |
| 部品 struct（`Health` など） | `USTRUCT` | |

## 3. エラー処理

| 本プロジェクト | UE |
|----------------|----|
| `ENGINE_ASSERT(cond, msg)` | `check(cond)` / `checkf(cond, fmt, ...)` |
| （該当なし） | `ensure(cond)`: 失敗を報告して続行 |
| 例外なし（`-fno-exceptions`） | 既定で例外無効 |
| `Result` / `optional` を返す | `bool` + 出力引数、`TOptional`、`TValueOrError` |

## 4. ゲームの構造

| 本プロジェクト | UE | 補足 |
|----------------|----|------|
| `sim::Step(config, state, input, dt)` | `UWorld::Tick` → 各 Actor / Component の `Tick` | UE は各オブジェクトが自分を更新する。本プロジェクトは 1 つの純粋関数が全体を更新する |
| `Step` 内の段階の順序 | Tick Group / Tick の前提条件 / Subsystem の更新順 | |
| 部品の集約（`Enemy { Health health; ... }`） | `AActor` + `UActorComponent` | UE のコンポーネントは実行時に付け外しできる |
| `std::variant` の `Behavior` | AI Controller / Behavior Tree / StateTree | |
| `GameState = variant<Title, Playing, GameOver>` | `AGameModeBase` / `AGameStateBase` / StateTree | |
| `Event`（`std::variant`）の配列 | Delegate（`DECLARE_MULTICAST_DELEGATE`）/ Gameplay Event | UE は購読者を直接呼ぶ。本プロジェクトはイベントを値として返す |
| `InputFrame` | Enhanced Input の Input Action の値 | |
| `GameConfig` / `DefaultConfig()` | `UDataAsset` / `UDataTable` / `UDeveloperSettings` | |
| content（JSON → `GameConfig`） | `FJsonObjectConverter::JsonObjectStringToUStruct` / DataTable の JSON インポート | |
| `DetectCollisions` → `Contact` 一覧 | 物理の Overlap / Hit イベント、`FHitResult` | |
| `BuildDrawList` → `Submit` | Scene Proxy（ゲームスレッドから描画スレッドへの受け渡し） | |
| `FxState`（見た目専用の状態） | Niagara などの演出 | ゲームのルールに影響しない処理をロジックから分ける |

## 5. UE で同じ設計を手書きする際の指針
- ゲームのルールは UObject に依存しない素の C++（`USTRUCT` + 自由関数 / static 関数）に置き、Actor / Component はそれを呼ぶ薄い層にする。
- `Step` のような純粋関数は Automation Test / Low-Level Tests でエンジンを起動せずにテストできる。
- イベントは Delegate を使いつつ、「何が起きたか」を struct で表して渡す。
