// アサート失敗のメッセージを出力したあと終了しない実行ファイル。
// abort() のダイアログなどでプロセスが固まった状態を再現し、検証スクリプトがそれを失敗と判定することを確かめる
#include <chrono>
#include <cstdio>
#include <thread>

int main()
{
    std::fputs("ENGINE_ASSERT failed: 1 + 1 == 3\n  message: assert failure test\n", stderr);
    std::fflush(stderr);
    while (true)
    {
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
}
