#include <engine/core/error.hpp>

#include <format>
#include <iterator>

namespace engine::core
{
Error MakeError(std::string message, std::source_location location)
{
    return Error{.message = std::move(message), .context = {}, .location = location};
}

std::string FormatError(const Error& error)
{
    std::string text = std::format("{} ({}:{})", error.message, error.location.file_name(), error.location.line());
    for (const std::string& item : error.context)
    {
        std::format_to(std::back_inserter(text), "\n  - {}", item);
    }
    return text;
}
} // namespace engine::core
