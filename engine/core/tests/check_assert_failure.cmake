# 使い方: cmake -DEXE=<実行ファイル> [-DTIMEOUT_SECONDS=<秒>] -P check_assert_failure.cmake
if(NOT DEFINED TIMEOUT_SECONDS)
    set(TIMEOUT_SECONDS 10)
endif()
execute_process(
    COMMAND "${EXE}"
    RESULT_VARIABLE result
    ERROR_VARIABLE stderrText
    TIMEOUT ${TIMEOUT_SECONDS}
)
# タイムアウトで強制終了された場合も result は "0" 以外になるため、先に判定する
if(result MATCHES "timeout")
    message(FATAL_ERROR "${TIMEOUT_SECONDS} 秒以内に終了しなかった（ダイアログなどで止まっている可能性がある）: ${result}")
endif()
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
