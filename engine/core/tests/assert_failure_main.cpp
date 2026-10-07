#include <engine/core/assert.hpp>

int main()
{
    ENGINE_ASSERT(1 + 1 == 3, "assert failure test");
    return 0;
}
