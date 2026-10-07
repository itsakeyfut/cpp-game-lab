#include "console.hpp"
#include "window.hpp"

#include <raylib.h>

namespace
{
constexpr int kScreenWidth = 1280;
constexpr int kScreenHeight = 720;
constexpr int kTargetFps = 60;
constexpr int kArenaGridSlices = 20;
constexpr float kArenaGridSpacing = 1.0f;

// アリーナ全体を斜め上から見下ろす固定カメラ
Camera3D MakeArenaCamera()
{
    return Camera3D{
        .position = Vector3{0.0f, 18.0f, 14.0f},
        .target = Vector3{0.0f, 0.0f, 0.0f},
        .up = Vector3{0.0f, 1.0f, 0.0f},
        .fovy = 45.0f,
        .projection = CAMERA_PERSPECTIVE,
    };
}
} // namespace

int main()
{
    arena::app::EnableUtf8Console();

    const arena::app::Window window{kScreenWidth, kScreenHeight, "Arena Survival"};
    SetTargetFPS(kTargetFps);

    const Camera3D camera = MakeArenaCamera();

    while (!WindowShouldClose())
    {
        BeginDrawing();
        ClearBackground(RAYWHITE);

        BeginMode3D(camera);
        DrawGrid(kArenaGridSlices, kArenaGridSpacing);
        EndMode3D();

        DrawText("Arena Survival - M0", 16, 16, 24, DARKGRAY);
        EndDrawing();
    }
    return 0;
}
