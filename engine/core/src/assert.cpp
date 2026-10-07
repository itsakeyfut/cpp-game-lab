#include <engine/core/assert.hpp>

#include <cstdio>
#include <cstdlib>
#include <string_view>

#if defined(_WIN32)
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#endif

namespace engine::core::detail
{
namespace
{
void WriteToStderr(std::string_view text)
{
    std::fwrite(text.data(), 1, text.size(), stderr);
}
} // namespace

void AssertionFailed(std::string_view expression, std::string_view message, std::source_location location)
{
    WriteToStderr("ENGINE_ASSERT failed: ");
    WriteToStderr(expression);
    WriteToStderr("\n  message: ");
    WriteToStderr(message);
    std::fprintf(stderr, "\n  at %s:%u\n", location.file_name(), static_cast<unsigned>(location.line()));
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
