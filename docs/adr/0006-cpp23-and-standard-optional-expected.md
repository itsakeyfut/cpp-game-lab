# ADR-0006: C++23 と標準の optional / expected

- 状態: 承認
- 日付: 2026-10-06

## 背景
FP スタイルの中心となる Option / Result 型をどう用意するかを決める必要があった。C++ のバージョンによって使える標準型が変わる。

## 決定
- C++23 を使う。
- Option は `std::optional<T>`、Result は `std::expected<T, E>` をそのまま使い、自作しない。
- 独自に設計するのはエラー型（`E` 側）と、標準にない小さな便利関数のみ（[error-handling.md](../error-handling.md)）。
- UE の型との対応と、UE 側で足りない操作の補い方を [ue-mapping.md](../ue-mapping.md) に記録する。

## 検討した選択肢
| 選択肢 | 長所 | 短所 |
|--------|------|------|
| **C++23 + 標準型** | `std::expected` と `and_then` / `transform` / `or_else` などのモナド操作が標準で揃う。誰でも読め、ツールも対応している | UE 5 は C++20 のため、一部の機能は UE でそのまま使えない → 対応表に代替を書く |
| C++20 + Result を自作 | 内部構造を学べる | 標準と同じものを作り直すことになり、実務的でない |
| C++20 + 外部ライブラリ（`tl::expected` 等） | C++20 で使える | C++23 が使える環境では不要 |

## 結果
- clang++ 20 + Visual Studio 2026 の標準ライブラリで、`-std=c++23` の `std::expected` と `std::optional` のモナド操作が動作することを確認済み（2026-10-06）。
- UE との対応: `std::optional` ↔ `TOptional`、`std::expected` ↔ `TValueOrError`、`std::variant` ↔ `TVariant`。
