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
    if(WIN32)
        # MSVC の標準ライブラリは ASan 有効時にコンテナ（string / vector / optional など）へ注釈を付ける。
        # vcpkg の依存ライブラリは ASan なしでビルドされており、注釈の有無が一致しないとリンクできないため無効にする
        add_compile_definitions(_DISABLE_STL_ANNOTATION)

        # ASan の実行時ライブラリ（DLL）の場所。実行ファイルの隣にコピーして使う
        execute_process(
            COMMAND "${CMAKE_CXX_COMPILER}" -print-resource-dir
            OUTPUT_VARIABLE cglClangResourceDir
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        file(TO_CMAKE_PATH "${cglClangResourceDir}" cglClangResourceDir)
        set(CGL_ASAN_RUNTIME_DLL "${cglClangResourceDir}/lib/windows/clang_rt.asan_dynamic-x86_64.dll")
        if(NOT EXISTS "${CGL_ASAN_RUNTIME_DLL}")
            message(FATAL_ERROR "ASan の実行時ライブラリが見つからない: ${CGL_ASAN_RUNTIME_DLL}")
        endif()
    endif()
endif()

# Windows で ASan を有効にした実行ファイルの隣に、ASan の実行時ライブラリをコピーする。それ以外では何もしない
function(cgl_copy_asan_runtime target)
    get_target_property(targetType ${target} TYPE)
    if(CGL_ENABLE_ASAN AND WIN32 AND targetType STREQUAL "EXECUTABLE")
        add_custom_command(TARGET ${target} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CGL_ASAN_RUNTIME_DLL}" "$<TARGET_FILE_DIR:${target}>"
            VERBATIM
        )
    endif()
endfunction()

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
    cgl_copy_asan_runtime(${target})
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
    # catch_discover_tests はビルド直後に実行ファイルを起動するため、それより前に登録する必要がある
    cgl_copy_asan_runtime(${target})
endfunction()
