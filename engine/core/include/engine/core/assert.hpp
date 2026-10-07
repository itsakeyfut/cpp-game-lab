#pragma once

#include <source_location>
#include <string_view>

namespace engine::core::detail
{
// アサート失敗時の処理。メッセージを出力して異常終了する
[[noreturn]] void AssertionFailed(std::string_view expression, std::string_view message,
                                  std::source_location location);
} // namespace engine::core::detail

// プログラムのバグ（起きてはいけない状態）を検出する。全ビルド構成で有効（docs/error-handling.md）
// 外部入力の検証には使わない（それは Result で扱う）
#define ENGINE_ASSERT(condition, message)                                                                    \
    do                                                                                                       \
    {                                                                                                        \
        if (!(condition)) [[unlikely]]                                                                       \
        {                                                                                                    \
            ::engine::core::detail::AssertionFailed(#condition, (message), std::source_location::current()); \
        }                                                                                                    \
    } while (false)
