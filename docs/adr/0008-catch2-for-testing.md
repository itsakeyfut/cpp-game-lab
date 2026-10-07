# ADR-0008: テストフレームワークに Catch2 v3 を使う

- 状態: 承認
- 日付: 2026-10-07

## 背景
純粋関数中心の設計（[ADR-0003](0003-functional-core-imperative-shell.md)）では、テストの大半が「入力 → 出力」の検証になる。

## 決定
テストフレームワークは Catch2 v3。

## 検討した選択肢
| 選択肢 | 長所 | 短所 |
|--------|------|------|
| **Catch2 v3** | `SECTION` で読みやすく書ける。`GENERATE` で入力を変えて同じテストを回せる。`BENCHMARK` がある。**UE 5 の Low-Level Tests は Catch2 を採用している** | 例外を内部で使う（→ テストのターゲットのみ例外を有効にする, [ADR-0009](0009-no-exceptions.md)） |
| GoogleTest | 業界で最も広く使われる。gMock によるモックが強力 | FP 中心の設計ではモックの出番が少なく、利点が小さい |
| doctest | 軽量・高速コンパイル | 機能は Catch2 のサブセット |

## 結果
- UE の Low-Level Tests と同じ書き方が身につく。
- 性能目標の計測にも Catch2 の `BENCHMARK` を使う。
