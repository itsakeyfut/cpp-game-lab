#pragma once

namespace arena::app
{
// Windows のコンソール出力を UTF-8 にする（日本語のエラーメッセージを文字化けさせない）。他の OS では何もしない
void EnableUtf8Console();
} // namespace arena::app
