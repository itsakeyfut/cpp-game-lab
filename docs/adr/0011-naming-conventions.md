# ADR-0011: 命名規則

- 状態: 承認
- 日付: 2026-10-07

## 背景
命名規則は全コードに影響し、後から変えにくい。学んだことを UE での手書き開発に活かしたい。

## 決定
型・関数は UE と同じ PascalCase、ただし UE の型接頭辞（`F` / `U` / `A` / `E` / `T`）と bool の `b` は付けない。規則の一覧は [coding-style.md](../coding-style.md) を参照。

| 対象 | 規則 |
|------|------|
| 型・関数 | PascalCase |
| 変数・引数・struct のメンバ | camelCase |
| class の private メンバ | camelCase + 末尾 `_` |
| bool | `is` / `has` / `can` で始める |
| 定数 | `k` + PascalCase |
| 名前空間 | 小文字 |
| ファイル名 | snake_case |
| マクロ | 大文字 + モジュール接頭辞 |

## 検討した選択肢
| 選択肢 | 長所 | 短所 |
|--------|------|------|
| **UE に近い PascalCase・接頭辞なし** | 型と関数が UE と同じで、UE のコードを読み書きするときに違和感が少ない。標準ライブラリ（snake_case）と自作コードが一目で区別できる | 標準ライブラリと書き方が混在する |
| 標準ライブラリと同じ snake_case | C++ コミュニティで一般的。書き方が統一される | UE と大きく異なる |
| UE と完全に同じ（接頭辞あり・変数も PascalCase） | UE の練習になる | 接頭辞は UE のリフレクション・GC と結びついた意味を持ち、それらがない本プロジェクトで真似ると誤解を生む |

## 結果
- clang-tidy の `readability-identifier-naming` で自動検査する（[ADR-0012](0012-code-quality-tools.md)）。
