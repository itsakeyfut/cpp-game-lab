# エラー処理の方針

リポジトリ全体に適用する。決定の経緯は [ADR-0006](adr/0006-cpp23-and-standard-optional-expected.md)、[ADR-0009](adr/0009-no-exceptions.md)、[ADR-0014](adr/0014-engine-core-scope.md) を参照。

---

## 1. 3 種類に分けて扱う

| 種類 | 例 | 扱い方 |
|------|----|--------|
| 想定内の失敗 | ファイルがない、JSON が壊れている、値が範囲外 | `engine::core::Result<T>`（= `std::expected<T, Error>`）で返す |
| 値がないことが正常 | 最も近い敵がいない、長さ 0 のベクトルの正規化 | `std::optional<T>` で返す |
| プログラムのバグ | 不変条件の違反、範囲外アクセス、ありえない分岐 | `ENGINE_ASSERT` で即停止 |

判断の目安: 「呼び出し側が対処できる / すべきか？」
- 対処すべき → `Result` または `optional`
- 対処しようがない（コードを直すしかない）→ アサート

## 2. 例外は使わない
- `throw` / `try` / `catch` を書かない。
- ゲーム本体のターゲットは `-fno-exceptions` でビルドする。テストのターゲットのみ例外を有効にする（Catch2 が内部で使うため）。
- 理由: ゲーム業界の慣行（性能・コードサイズ・プラットフォーム制約）。UE も既定で例外は無効。失敗が関数の型に現れ、FP の方針と一致する。

## 3. `Error` 型
```cpp
namespace engine::core
{
struct Error
{
    std::string message;                 // 何が起きたか
    std::vector<std::string> context;    // 外側の呼び出し元が付け足す文脈（内側 → 外側の順）
    std::source_location location;       // 発生場所
};

template <class T>
using Result = std::expected<T, Error>;
}
```
- エラーは汎用の `Error` 1 種類から始める。呼び出し側がエラーの種類で分岐する必要が出たら、そのモジュールに専用の `enum class` を追加する。
- 文脈は失敗が外側へ伝わる途中で付け足す:
```cpp
return ReadFile(path)
    .and_then(ParseGameConfig)
    .transform_error(WithContext(std::format("{} の読み込み中", path.string())));
```

## 4. つなぎ方（モナド操作）
| 操作 | 意味 |
|------|------|
| `and_then(f)` | 成功なら `f`（`Result` を返す関数）を続けて実行。失敗ならそのまま |
| `transform(f)` | 成功なら値を `f` で変換 |
| `or_else(f)` | 失敗なら `f` で回復を試みる |
| `transform_error(f)` | 失敗ならエラーを `f` で変換（文脈の追加など） |
| `value_or(x)` | 失敗・値なしなら `x` |

- `if (!result) return std::unexpected(result.error());` と書く前に、上の操作でつなげないか検討する。読みやすさが落ちる場合は早期 return でよい。
- `*result` / `.value()` で中身を取り出すのは、直前に成功を確認した場合のみ。

## 5. まとめて検証する（Validation）
データファイルの検証は最初のエラーで止めず、全項目を検証してエラーをまとめて返す。データを編集する人が 1 回で全ての誤りを直せるようにするため。
```cpp
// 全要素が成功なら値の配列、1 つでも失敗なら全エラーをまとめた Error を返す
template <class T>
Result<std::vector<T>> Collect(std::vector<Result<T>> results);
```

## 6. アサート
```cpp
ENGINE_ASSERT(health.max > 0, "最大 HP は正の値でなければならない");
```
- 失敗時に条件式・メッセージ・ファイル・行を出力し、停止する。デバッガ接続時はブレークする。
- 全ビルド構成で有効（性能上の問題が計測で確認されたら release で無効化を検討する）。
- 外部入力（ファイル・ユーザー入力）の検証には使わない。それは「想定内の失敗」なので `Result` で扱う。

## 7. 境界での扱い
- app は `Result` の失敗を受け取ったら、`message` と `context`（外側から順）を表示して終了コード 1 で終了する。
- sim は失敗しない設計にする（入力は検証済みの `GameConfig` と `InputFrame` のみ）。sim 内の異常はアサートで扱う。
