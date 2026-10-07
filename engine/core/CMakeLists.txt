add_library(engine_core STATIC
    src/error.cpp
)
add_library(engine::core ALIAS engine_core)

target_include_directories(engine_core PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)
cgl_configure_target(engine_core)
cgl_disable_exceptions(engine_core)
