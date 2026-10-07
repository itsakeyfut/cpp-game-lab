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

# Windows の実行ファイルで、ANSI コードページ（argv や fopen などの char 版 API）を UTF-8 にする
# （docs/adr/0016-utf8-code-page-on-windows.md）。他の OS では何もしない
function(cgl_use_utf8_code_page target)
    if(WIN32)
        target_sources(${target} PRIVATE "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/windows/utf8.manifest")
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
    # CTest は日本語のテスト名をコマンドライン引数で渡すため、argv を UTF-8 で受け取る必要がある
    cgl_use_utf8_code_page(${target})
endfunction()
