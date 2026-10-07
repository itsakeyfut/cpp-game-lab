#pragma once

#include <raylib.h>

namespace arena::app
{
// raylib のウィンドウを開き、破棄時に閉じる
class Window
{
  public:
    Window(int width, int height, const char* title)
    {
        InitWindow(width, height, title);
    }

    ~Window()
    {
        CloseWindow();
    }

    Window(const Window&) = delete;
    Window& operator=(const Window&) = delete;
    Window(Window&&) = delete;
    Window& operator=(Window&&) = delete;
};
} // namespace arena::app
