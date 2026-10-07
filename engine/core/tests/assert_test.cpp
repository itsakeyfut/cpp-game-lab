#include <engine/core/assert.hpp>

#include <catch2/catch_test_macros.hpp>

TEST_CASE("ENGINE_ASSERT: 条件が真なら何もしない")
{
    ENGINE_ASSERT(1 + 1 == 2, "算数が壊れている");
    SUCCEED();
}

TEST_CASE("ENGINE_ASSERT: 条件式を 1 回だけ評価する")
{
    int evaluations = 0;
    ENGINE_ASSERT(++evaluations == 1, "評価回数");
    CHECK(evaluations == 1);
}
