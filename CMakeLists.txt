cmake_minimum_required(VERSION 3.28)

# Windows では依存ライブラリを静的ライブラリ（C ランタイムは DLL 版）で取得する。
# DLL を実行ファイルの横に並べる必要がなくなる。
if(CMAKE_HOST_WIN32 AND NOT DEFINED VCPKG_TARGET_TRIPLET)
    set(VCPKG_TARGET_TRIPLET "x64-windows-static-md" CACHE STRING "")
endif()

project(cpp-game-lab
    VERSION 0.0.1
    DESCRIPTION "ゲームエンジンを使わずに C++ で作る題材別のゲーム"
    LANGUAGES C CXX
)

option(CGL_BUILD_TESTS "テストをビルドする" ON)
option(CGL_WARNINGS_AS_ERRORS "警告をエラーとして扱う" OFF)
option(CGL_ENABLE_CLANG_TIDY "ビルド時に clang-tidy を実行する" OFF)
option(CGL_ENABLE_ASAN "AddressSanitizer を有効にする" OFF)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(ProjectOptions)

find_package(raylib CONFIG REQUIRED)
# vcpkg の raylib（6.0）は静的ライブラリの依存（glfw と OS のライブラリ）を伝播しないため、ここで補う
find_package(glfw3 CONFIG REQUIRED)
if(WIN32)
    set_property(TARGET raylib APPEND PROPERTY INTERFACE_LINK_LIBRARIES glfw opengl32 winmm)
else()
    find_package(OpenGL REQUIRED)
    find_package(Threads REQUIRED)
    set_property(TARGET raylib APPEND PROPERTY INTERFACE_LINK_LIBRARIES
        glfw OpenGL::GL Threads::Threads ${CMAKE_DL_LIBS} m
    )
endif()

if(CGL_BUILD_TESTS)
    enable_testing()
    find_package(Catch2 3 CONFIG REQUIRED)
    include(Catch)
endif()

add_subdirectory(engine)
add_subdirectory(games)
