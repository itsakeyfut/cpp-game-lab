add_executable(arena_app
    src/console.cpp
    src/main.cpp
)
target_link_libraries(arena_app PRIVATE engine::core raylib)
cgl_configure_target(arena_app)
cgl_disable_exceptions(arena_app)
cgl_use_utf8_code_page(arena_app)
