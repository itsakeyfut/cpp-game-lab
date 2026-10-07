add_library(engine_core STATIC
    src/assert.cpp
    src/error.cpp
)
add_library(engine::core ALIAS engine_core)

target_include_directories(engine_core PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)
cgl_configure_target(engine_core)
cgl_disable_exceptions(engine_core)

if(CGL_BUILD_TESTS)
    add_executable(engine_core_tests
        tests/error_test.cpp
        tests/assert_test.cpp
    )
    target_link_libraries(engine_core_tests PRIVATE engine::core Catch2::Catch2WithMain)
    cgl_configure_test_target(engine_core_tests)
    catch_discover_tests(engine_core_tests)

    # アサート失敗時に、メッセージを出力してダイアログなしで終了することを確認する
    add_executable(engine_core_assert_failure tests/assert_failure_main.cpp)
    target_link_libraries(engine_core_assert_failure PRIVATE engine::core)
    cgl_configure_test_target(engine_core_assert_failure)
    add_test(NAME engine_core_assert_failure
        COMMAND ${CMAKE_COMMAND}
            -DEXE=$<TARGET_FILE:engine_core_assert_failure>
            -P ${CMAKE_CURRENT_SOURCE_DIR}/tests/check_assert_failure.cmake
    )
endif()
