# ドキュメント一覧

## 全体
| ファイル | 内容 |
|----------|------|
| [project-overview.md](project-overview.md) | プロジェクトの目的・学習目標・設計の原則・題材シリーズ |
| [repository-structure.md](repository-structure.md) | ディレクトリ構成・モジュール・依存のルール・名前空間 |
| [coding-style.md](coding-style.md) | コーディング規約（命名・ファイル・設計の原則・テスト） |
| [error-handling.md](error-handling.md) | エラー処理の方針（Result / Option / アサート） |
| [git-workflow.md](git-workflow.md) | ブランチ・コミット・タグ・CI |
| [ue-mapping.md](ue-mapping.md) | 本プロジェクトの概念と Unreal Engine の対応表 |
| [adr/](adr/README.md) | 決定記録（ADR）: リポジトリ全体に関わる決定と、その理由・検討した選択肢 |

## 題材ごと
| 題材 | 設計書 | 決定記録 |
|------|--------|----------|
| アリーナ・サバイバル | [design.md](../games/arena-survival/docs/design.md) | [adr/](../games/arena-survival/docs/adr/README.md) |

## 文書の使い分け
- **ガイド**（`project-overview.md`、`coding-style.md` など）: 「今どうなっているか・どう書くか」。常に最新に保つ。
- **ADR**（`adr/`）: 「なぜそう決めたか・何と比べたか」。一度書いたら内容は書き換えず、方針を変えるときは新しい ADR を追加して古い ADR の状態を「廃止」にする。変遷を追うための記録。
