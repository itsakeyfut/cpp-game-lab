#include <engine/core/assert.hpp>

#include <cstdio>
#include <cstdlib>
#include <print>
#include <string_view>

#if defined(_WIN32)
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#endif

namespace engine::core::detail
{
void AssertionFailed(std::string_view expression, std::string_view message, std::source_location location)
{
    std::println(stderr, "ENGINE_ASSERT failed: {}\n  message: {}\n  at {}:{}", expression, message,
                 location.file_name(), location.line());
    std::fflush(stderr);

#if defined(_WIN32)
    if (IsDebuggerPresent() != 0)
    {
        __debugbreak();
    }
    // abort() のダイアログと Windows エラー報告を出さない（CI で止まらないようにする）
    _set_abort_behavior(0, _WRITE_ABORT_MSG | _CALL_REPORTFAULT);
#endif
    std::abort();
}
} // namespace engine::core::detail
