# cpp-game-lab

C++ で、ゲームエンジンを使わずにゲームモデルを定義し、題材ごとに小さなゲームを作るリポジトリ。
目的と方針は [docs/project-overview.md](docs/project-overview.md)、文書の一覧は [docs/README.md](docs/README.md) を参照。

## 題材
| 題材 | ディレクトリ |
|------|--------------|
| アリーナ・サバイバル | [games/arena-survival](games/arena-survival/README.md) |

## 必要なツール
| ツール | バージョン |
|--------|-----------|
| clang / clang++ | 20 以上 |
| CMake | 3.28 以上 |
| Ninja | 1.11 以上 |
| vcpkg | 環境変数 `VCPKG_ROOT` にインストール先を設定する |
| Visual Studio 2026 または Build Tools（Windows のみ） | MSVC の標準ライブラリと Windows SDK に使う |

## ビルド
```sh
cmake --preset debug          # 構成（初回は vcpkg が依存ライブラリをビルドするため時間がかかる）
cmake --build --preset debug  # ビルド
ctest --preset debug          # テスト
```

| プリセット | 用途 |
|------------|------|
| `debug` | 開発用 |
| `release` | 最適化ビルド |
| `asan` | AddressSanitizer でメモリ破壊を検出 |
| `ci` | CI 用（警告をエラー扱い、clang-tidy 有効） |

## トラブルシューティング
- `Could not find toolchain file: /scripts/buildsystems/vcpkg.cmake` → 環境変数 `VCPKG_ROOT` が設定されていない。vcpkg のインストール先を設定してからターミナルを開き直す。
