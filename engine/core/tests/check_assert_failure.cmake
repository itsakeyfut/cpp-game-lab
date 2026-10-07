# 使い方: cmake -DEXE=<実行ファイル> -P check_assert_failure.cmake
execute_process(
    COMMAND "${EXE}"
    RESULT_VARIABLE result
    ERROR_VARIABLE stderrText
    TIMEOUT 10
)
if(result STREQUAL "0")
    message(FATAL_ERROR "アサート失敗で異常終了するはずが、正常終了した")
endif()
if(NOT stderrText MATCHES "ENGINE_ASSERT failed: 1 [+] 1 == 3")
    message(FATAL_ERROR "条件式が出力されていない:\n${stderrText}")
endif()
if(NOT stderrText MATCHES "message: assert failure test")
    message(FATAL_ERROR "メッセージが出力されていない:\n${stderrText}")
endif()
message(STATUS "アサート失敗を確認: 終了状態 = ${result}")
