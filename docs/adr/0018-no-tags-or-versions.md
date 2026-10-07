# ADR-0018: タグとバージョン番号を使わない

- 状態: 承認
- 日付: 2026-10-07

## 背景
- [ADR-0013](0013-git-workflow-and-ci.md) では、題材ごとのマイルストーンでタグ `<題材>/vX.Y.Z` を付けることにしていた。[アリーナ・サバイバルの ADR-0003](../../games/arena-survival/docs/adr/0003-milestones-and-late-data-driven.md) も同じ前提で、マイルストーンごとのタグを決めていた。
- このリポジトリは配布するソフトウェアではなく学習記録であり、利用者に向けたリリースがない。
- [ADR-0015](0015-public-repo-issues-and-labels.md) で、マイルストーンを親 Issue と子 Issue（sub-issues）で管理するようになった。

## 決定
- Git のタグを作らない。
- バージョン番号を付けない（CMake の `project(VERSION)`、`vcpkg.json` の `version` 系の項目を書かない）。
- マイルストーンは親 Issue（`T-Tracking-Issue`）で管理する。マイルストーンの区切りは、親 Issue が閉じた時点の `main` のコミットとする。
- ADR-0013 のタグに関する決定と、アリーナ・サバイバルの ADR-0003 の「各マイルストーンでタグを付ける」は、この ADR で置き換える。

## 検討した選択肢
| 選択肢 | 長所 | 短所 |
|--------|------|------|
| **タグ・バージョンを使わず、親 Issue で区切る** | リリースのないプロジェクトに不要な運用を持ち込まない。区切りの理由と作業の一覧が親 Issue にまとまる | 「その時点の構成」を名前で取り出せない → 親 Issue に記録したコミットを使う |
| マイルストーンごとにタグを付ける（従来） | `git checkout <タグ>` で取り出せる | リリースがないのにバージョンを管理することになる |

## 結果
- 立ち上げ（M0）の完了時に付けたタグ `arena-survival/v0.0.1` は削除した。M0 の区切りは親 Issue #1 を閉じた時点の `main` とする。
- ガイド文書（[git-workflow.md](../git-workflow.md)、[design.md](../../games/arena-survival/docs/design.md)）からタグの記述を取り除いた。

## 関連
- [ADR-0013](0013-git-workflow-and-ci.md)、[ADR-0015](0015-public-repo-issues-and-labels.md)、[アリーナ・サバイバルの ADR-0003](../../games/arena-survival/docs/adr/0003-milestones-and-late-data-driven.md)
