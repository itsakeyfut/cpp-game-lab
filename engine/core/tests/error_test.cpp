#include <engine/core/error.hpp>

#include <catch2/catch_test_macros.hpp>

#include <format>
#include <source_location>
#include <string>

using engine::core::Error;
using engine::core::FormatError;
using engine::core::MakeError;
using engine::core::Result;
using engine::core::WithContext;

namespace
{
Result<int> ParsePositive(int value)
{
    if (value <= 0)
    {
        return std::unexpected(MakeError("正の値ではない"));
    }
    return value;
}
} // namespace

TEST_CASE("MakeError: メッセージと呼び出し位置を記録する")
{
    const std::source_location here = std::source_location::current();
    const Error error = MakeError("壊れたデータ");

    CHECK(error.message == "壊れたデータ");
    CHECK(error.context.empty());
    CHECK(error.location.line() == here.line() + 1);
    CHECK(std::string{error.location.file_name()} == here.file_name());
}

TEST_CASE("Result: 成功時は値を、失敗時はエラーを持つ")
{
    const Result<int> ok = ParsePositive(3);
    REQUIRE(ok.has_value());
    CHECK(*ok == 3);

    const Result<int> ng = ParsePositive(-1);
    REQUIRE_FALSE(ng.has_value());
    CHECK(ng.error().message == "正の値ではない");
}

TEST_CASE("WithContext: 失敗時に文脈を内側から外側の順で追加する")
{
    const Result<int> result = ParsePositive(0)
                                   .transform_error(WithContext("hp の検証中"))
                                   .transform_error(WithContext("enemies.json の読み込み中"));

    REQUIRE_FALSE(result.has_value());
    REQUIRE(result.error().context.size() == 2);
    CHECK(result.error().context[0] == "hp の検証中");
    CHECK(result.error().context[1] == "enemies.json の読み込み中");
}

TEST_CASE("WithContext: 成功時は値を変えない")
{
    const Result<int> result = ParsePositive(5).transform_error(WithContext("使われない文脈"));

    REQUIRE(result.has_value());
    CHECK(*result == 5);
}

TEST_CASE("FormatError: メッセージ・位置・文脈を整形する")
{
    Error error = MakeError("hp は正の値でなければならない");
    error.context = {"hp の検証中", "enemies.json の読み込み中"};

    const std::string expected = std::format("hp は正の値でなければならない ({}:{})\n"
                                             "  - hp の検証中\n"
                                             "  - enemies.json の読み込み中",
                                             error.location.file_name(), error.location.line());
    CHECK(FormatError(error) == expected);
}

TEST_CASE("FormatError: 文脈がない場合は 1 行")
{
    const Error error = MakeError("ファイルがない");

    const std::string expected =
        std::format("ファイルがない ({}:{})", error.location.file_name(), error.location.line());
    CHECK(FormatError(error) == expected);
}
