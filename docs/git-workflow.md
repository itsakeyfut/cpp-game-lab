# Git 運用

決定の理由は [ADR-0013](adr/0013-git-workflow-and-ci.md)、[ADR-0015](adr/0015-public-repo-issues-and-labels.md)、[ADR-0018](adr/0018-no-tags-or-versions.md) を参照。

## 1. リポジトリ
- GitHub の Public リポジトリ。ライセンスは当面付けない。
- 秘密情報はコミットしない。個人用の作業ファイルは `.gitignore`、個人の環境固有の除外は `.git/info/exclude`（コミットされない）に書く。

## 2. 作業の流れ
```
Issue を起票 → 作業ブランチを作る → 実装・ビルド・テスト → PR を出す → 所有者がマージ → 次の Issue へ
```
- 作業ごとに Issue を起票する。Issue には「目的・作業内容・完了条件・参照」を書く。
- まとまった目標（マイルストーンなど）は親 Issue（`T-Tracking-Issue`）を作り、作業を子 Issue（GitHub の sub-issues）に分ける。子 Issue がすべて閉じたら親を閉じる。
- 1 Issue = 1 作業ブランチ = 1 PR。
- PR の説明に `Closes #<番号>` を書き、マージ時に Issue が閉じるようにする。
- **マージはリポジトリの所有者が行う。** 作業者は PR を出したら止まり、マージ後に `main` を取り込んでから次の Issue に進む。

## 3. ラベル
接頭辞ごとに 1 つずつ付ける（`A-` は複数可）。

| 接頭辞 | 分類 | ラベル | 付け方 |
|--------|------|--------|--------|
| `S-` | 状態 | `Needs-Design` | 実装の前に設計が必要 |
| | | `Ready-For-Implementation` | 設計が固まり、完了条件を確認できる。着手できる |
| | | `In-Progress` | 作業中 |
| | | `Blocked` | まだ実装できず、調べている実験もない |
| | | `Experimenting` | 止まっているが、原因を確かめる実験を進めている |
| `T-` | 種類 | `Feat` / `Bug` / `Doc` / `Maintenance` / `Perf` | 機能 / 不具合 / 文書・ADR / 振る舞いを変えない整理 / 計測に基づく性能改善 |
| | | `Experiment` | 使い捨てのブランチで試して答えを出す問い |
| | | `Tracking-Issue` | 親 Issue |
| `A-` | 領域 | `engine-core` / `arena-sim` / `arena-content` / `arena-app` | CMake のモジュール単位 |
| | | `build` / `ci` / `docs` | CMake・vcpkg・品質ツール / GitHub Actions / 文書 |
| `D-` | 難しさ | `Trivial` / `Straightforward` / `Modest` / `Complex` | 機械的 / やり方が 1 つ / 多少の設計 / 本格的な調査が要る |
| | | `Cpp-Semantics` | C++ の規格の定めで答えが決まる。規格の該当箇所を示す |
| `P-` | 優先度 | `Critical` | ビルドできない・起動しない・決定論が壊れる。最優先 |
| | | `High` / `Medium` / `Low` | 他の Issue が待っている / 標準 / 後回しでよい |

題材やモジュールを追加したら、`A-<題材の短縮名>-<module>` のラベルを追加する。

## 4. ブランチ
- `main`: 常にビルドとテストが通る状態を保つ。直接コミットしない。
- 作業ブランチ: `<種類>/<スコープ>-<内容>` の形で作り、短期間でプルリクエストにして `main` に取り込む。スコープがない（リポジトリ全体の）場合は `<種類>/<内容>`。
  - 例: `feat/arena-wave-spawner`、`refactor/engine-error-context`、`build/ci-linux`、`docs/repo-operations`
- プルリクエストの説明は次の形式で書く（`.github/pull_request_template.md`）。変遷を追うための記録になる。

| 節 | 書くこと |
|----|----------|
| 先頭 | `Closes #<番号>` |
| `Objective` | 何のための変更か。解決する問題・満たす要件。関連する ADR・設計書 |
| `Solution` | どう変えたか。主な変更点とその理由。採らなかった案があればそれも |
| `Verification` | どう確かめたか。実行したコマンドと結果、手動で確認したこと |

## 5. コミットメッセージ
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

## 6. コミットの粒度
- 1 コミット = 1 つの意図。
- 各コミットでビルドとテストが通ること。

## 7. マイルストーン
タグとバージョン番号は使わない（[ADR-0018](adr/0018-no-tags-or-versions.md)）。
- マイルストーンは親 Issue（`T-Tracking-Issue`）で管理する。
- マイルストーンの区切りは、親 Issue が閉じた時点の `main` のコミット。親 Issue を閉じるときに、そのコミットをコメントに書く。

## 8. CI（GitHub Actions）
| ジョブ | 内容 |
|--------|------|
| ビルド・テスト | Windows（clang）と Linux（clang）で `ci` プリセットを使い、全題材をビルドしてテストする |
| 整形チェック | clang-format の差分がないこと |
| 静的解析 | clang-tidy の警告がないこと（`ci` プリセットのビルドで実行） |
| AddressSanitizer | Windows と Linux で `asan` プリセットを使い、全題材をビルドしてテストする（[ADR-0017](adr/0017-run-asan-in-ci.md)） |
| ベンチマーク | 性能目標の確認（アリーナ・サバイバル M7 以降） |

共有部品（`engine/`）の変更で古い題材が壊れた場合に即座に分かるよう、常に全題材をビルドする。

ワークフローの安全のため、次を守る。
- `GITHUB_TOKEN` の権限は `contents: read` のみ。
- Actions はコミットの SHA で固定し、コメントにバージョンを書く。
- 外部のスクリプトを取得してそのまま実行しない。apt リポジトリは署名鍵のフィンガープリントを照合して登録する（`.github/scripts/add-llvm-apt-repo.sh`）。
- vcpkg のバイナリキャッシュは `main` への push でのみ保存し、PR では復元のみ。
