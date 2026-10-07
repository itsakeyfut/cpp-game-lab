#pragma once

#include <expected>
#include <source_location>
#include <string>
#include <utility>
#include <vector>

namespace engine::core
{
// 想定内の失敗を表す値（docs/error-handling.md）
struct Error
{
    std::string message;              // 何が起きたか
    std::vector<std::string> context; // 外側の呼び出し元が追加する文脈（内側 → 外側の順）
    std::source_location location;    // 発生場所
};

template <class T>
using Result = std::expected<T, Error>;

// 呼び出し位置を記録した Error を作る
[[nodiscard]] Error MakeError(std::string message,
                              std::source_location location = std::source_location::current());

// transform_error に渡す関数オブジェクトを返す。失敗時のエラーに文脈を追加する
[[nodiscard]] inline auto WithContext(std::string description)
{
    return [description = std::move(description)](Error error) -> Error {
        error.context.push_back(description);
        return error;
    };
}

// 人が読む形式に整形する。例:
//   hp は正の値でなければならない (enemy_def.cpp:42)
//     - hp の検証中
//     - enemies.json の読み込み中
[[nodiscard]] std::string FormatError(const Error& error);
} // namespace engine::core
