include_guard(GLOBAL)

include(CompilerWarnings)

if(CGL_ENABLE_CLANG_TIDY)
    find_program(CGL_CLANG_TIDY_EXE NAMES clang-tidy REQUIRED)
    set(CGL_CLANG_TIDY_COMMAND "${CGL_CLANG_TIDY_EXE}")
    if(CGL_WARNINGS_AS_ERRORS)
        list(APPEND CGL_CLANG_TIDY_COMMAND "--warnings-as-errors=*")
    endif()
endif()

if(CGL_ENABLE_ASAN)
    add_compile_options(-fsanitize=address -fno-omit-frame-pointer)
    add_link_options(-fsanitize=address)
endif()

# ゲーム本体（ライブラリ・実行ファイル）に共通の設定
function(cgl_configure_target target)
    set_target_properties(${target} PROPERTIES
        CXX_STANDARD 23
        CXX_STANDARD_REQUIRED ON
        CXX_EXTENSIONS OFF
    )
    cgl_set_warnings(${target})
    if(CGL_ENABLE_CLANG_TIDY)
        set_target_properties(${target} PROPERTIES CXX_CLANG_TIDY "${CGL_CLANG_TIDY_COMMAND}")
    endif()
endfunction()

# 例外を無効にする（docs/adr/0009-no-exceptions.md）
function(cgl_disable_exceptions target)
    target_compile_options(${target} PRIVATE -fno-exceptions)
    if(WIN32)
        # MSVC の標準ライブラリに例外を使わない実装を選ばせる
        target_compile_definitions(${target} PRIVATE _HAS_EXCEPTIONS=0)
    endif()
endfunction()

# テスト用ターゲットの設定（Catch2 が例外を使うため例外は有効のまま。clang-tidy は対象外）
function(cgl_configure_test_target target)
    set_target_properties(${target} PROPERTIES
        CXX_STANDARD 23
        CXX_STANDARD_REQUIRED ON
        CXX_EXTENSIONS OFF
    )
    cgl_set_warnings(${target})
endfunction()
