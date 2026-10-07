#include "console.hpp"

#if defined(_WIN32)
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#endif

namespace arena::app
{
void EnableUtf8Console()
{
#if defined(_WIN32)
    SetConsoleOutputCP(CP_UTF8);
#endif
}
} // namespace arena::app
