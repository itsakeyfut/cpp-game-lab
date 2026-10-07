# ADR-0007: ツールチェーンと依存管理（CMake + Ninja + clang + vcpkg）

- 状態: 承認
- 日付: 2026-10-07

## 背景
- C++ プロジェクトの立ち上げで何から着手すべきかの手本にしたい。ビルド設定・設定ファイルはゲーム業界の実務で一般的なベストプラクティスに従う。
- 外部ライブラリ（raylib、テストフレームワーク、JSON パーサ）の取得方法を決める必要があった。

## 決定
- ビルドは CMake + Ninja。構成は `CMakePresets.json` で共有する。
- コンパイラは clang / clang++（Windows では MSVC の標準ライブラリを使う `x86_64-pc-windows-msvc` ターゲット）。
- 外部ライブラリは **vcpkg マニフェストモード**で管理する（`vcpkg.json` に依存とバージョンを宣言し、`vcpkg-configuration.json` で基準バージョンを固定する）。

## 検討した選択肢（依存管理）
| 選択肢 | 長所 | 短所 |
|--------|------|------|
| **vcpkg マニフェストモード** | 宣言的でバージョン固定ができる。バイナリキャッシュで 2 回目以降が速い。現在の C++ で最も一般的に推奨される方法 | vcpkg 本体のインストールが最初に 1 回必要 |
| CMake FetchContent | 追加インストール不要 | 依存の宣言が CMake に散らばる。クリーンビルドのたびに再ビルド |
| ThirdParty にソースを同梱（vendoring） | ゲーム会社の伝統的な方法（UE の `Engine/Source/ThirdParty` も同方式）。オフラインで完結 | リポジトリが重くなる。更新が手作業 |

## 結果
- UE は外部ライブラリをソースごと同梱して `.Build.cs` で参照する。本プロジェクトとの違いは [ue-mapping.md](../ue-mapping.md) に記録する。
- 開発時点の環境: Windows 11、Visual Studio Community 2026、clang 20.1.6、CMake 4.0.3、Ninja。
