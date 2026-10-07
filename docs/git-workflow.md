# Git 運用

決定の理由は [ADR-0013](adr/0013-git-workflow-and-ci.md) を参照。

## 1. ブランチ
- `main`: 常にビルドとテストが通る状態を保つ。直接コミットしない。
- 作業ブランチ: `<種類>/<スコープ>-<内容>` の形で作り、短期間でプルリクエストにして `main` に取り込む。
  - 例: `feat/arena-wave-spawner`、`refactor/engine-error-context`、`build/ci-linux`
- プルリクエストの説明に「何を・なぜ変えたか」を書く。変遷を追うための記録になる。

## 2. コミットメッセージ
[Conventional Commits](https://www.conventionalcommits.org/) にスコープを付ける。
```
<種類>(<スコープ>): <要約>

<本文: なぜ変えたか>
```

| 種類 | 用途 |
|------|------|
| `feat` | 機能の追加 |
| `fix` | バグ修正 |
| `refactor` | 振る舞いを変えない構造の変更 |
| `test` | テストの追加・修正 |
| `perf` | 性能改善 |
| `build` | CMake・vcpkg・ツール設定 |
| `ci` | CI の設定 |
| `docs` | 文書 |
| `chore` | その他の雑務 |

| スコープ | 対象 |
|----------|------|
| `engine` | `engine/` 配下 |
| `arena` | `games/arena-survival/` 配下 |
| （題材を追加するたびに追加） | |
| なし | リポジトリ全体（最上位の CMake、CI、`docs/` など） |

例:
```
feat(arena): 突撃型の敵がプレイヤーへ向かって移動する
refactor(engine): Staged を arena から engine/core へ移す
build: vcpkg に glaze を追加
```

題材ごとに履歴を絞り込む: `git log --grep="(arena)"`

## 3. コミットの粒度
- 1 コミット = 1 つの意図。
- 各コミットでビルドとテストが通ること。

## 4. タグ
題材ごとのマイルストーンで `<題材>/vX.Y.Z` を付ける。
- 例: `arena-survival/v0.0.1`（立ち上げ）、`arena-survival/v1.0.0`
- 「この時点の構成」を `git checkout arena-survival/v0.3.0` で丸ごと取り出せる。

## 5. CI（GitHub Actions）
| ジョブ | 内容 |
|--------|------|
| ビルド・テスト | Windows（clang）と Linux（clang）で `ci` プリセットを使い、全題材をビルドしてテストする |
| 整形チェック | clang-format の差分がないこと |
| 静的解析 | clang-tidy の警告がないこと |
| ベンチマーク | 性能目標の確認（アリーナ・サバイバル M7 以降） |

共有部品（`engine/`）の変更で古い題材が壊れた場合に即座に分かるよう、常に全題材をビルドする。
