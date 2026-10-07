# ADR-0016: Windows の実行ファイルは UTF-8 のコードページで動かす

- 状態: 承認
- 日付: 2026-10-07

## 背景
- 文書・コメント・テスト名は日本語で書く（[coding-style.md](../coding-style.md)）。ソースファイルは UTF-8 で、文字列リテラルも UTF-8 のバイト列になる。
- `engine::core` のテストを CTest で実行したところ、Windows で全件が「No test cases matched」で失敗した。テストの実行ファイルを直接実行すると全件成功した。
- 原因: CTest（`catch_discover_tests`）はテストを 1 件ずつ、テスト名をコマンドライン引数に渡して実行する。Windows では `main` の `argv` がシステムの ANSI コードページ（日本語環境では 932 = Shift_JIS）に変換されるため、UTF-8 で登録されたテスト名と一致しない。
- 同じ問題は、日本語を含むファイルパスを `char` 版の API（`fopen`、`std::filesystem::path` の `char` 文字列からの構築など）で扱う場合にも起きる。

## 決定
- Windows の実行ファイルには、アプリケーションマニフェストで `activeCodePage` = `UTF-8` を指定する。プロセスの ANSI コードページが UTF-8 になり、`argv` や `char` 版の API が UTF-8 で動く。
- マニフェストは `cmake/windows/utf8.manifest` に置き、CMake 関数 `cgl_use_utf8_code_page(<target>)` で実行ファイルに埋め込む。他の OS では何もしない。
- テスト用ターゲット（`cgl_configure_test_target`）では自動で適用する。ゲームの実行ファイルにも適用する。
- コンソールへの出力の文字コードは別の設定（`SetConsoleOutputCP`）のため、この決定の対象外。

## 検討した選択肢
| 選択肢 | 長所 | 短所 |
|--------|------|------|
| **マニフェストで UTF-8 コードページを指定** | Microsoft が推奨する方法。コードを変えずに、プロセス全体の `char` 版 API が UTF-8 になる。日本語のテスト名をそのまま使える | Windows 10 1903 以降が必要。マニフェストという Windows 固有の仕組みが 1 つ増える |
| テスト名を英語（ASCII）にする | 追加の仕組みが不要 | 「日本語で書く」方針と、テスト名の書き方（「対象: 期待する振る舞い」）に反する。ファイルパスなど他の場面の問題は残る |
| CTest にテストを 1 件ずつ登録せず、実行ファイル単位で登録する | 引数を渡さないので問題が起きない | CTest でテストごとの成否が見えなくなる。根本原因（`argv` の文字コード）は残る |
| `wmain` / `GetCommandLineW` で UTF-16 を受け取り変換する | マニフェスト不要 | Catch2 の `main` を差し替える必要がある。全ての `char` 版 API に変換を挟むことになる |

## 結果
- Windows でも日本語のテスト名を CTest で 1 件ずつ実行できる。
- 動作要件は Windows 10 1903 以降になる。
- UE との対応: UE は内部の文字列を UTF-16（`TCHAR` = `wchar_t`）で扱い、OS の API も wide 版を呼ぶため、この問題が起きない。本プロジェクトは標準 C++ の `char` + UTF-8 で書き、Windows 側をマニフェストで UTF-8 に合わせる。
