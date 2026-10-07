#!/usr/bin/env bash
# apt.llvm.org のリポジトリを登録する。署名鍵はフィンガープリントを照合してから登録する
# 環境変数: LLVM_VERSION（例: 20）、LLVM_KEY_FINGERPRINT
set -euo pipefail

: "${LLVM_VERSION:?}"
: "${LLVM_KEY_FINGERPRINT:?}"

codename="$(. /etc/os-release && echo "${VERSION_CODENAME}")"
keyring=/usr/share/keyrings/apt.llvm.org.gpg
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key -o "${tmp}/llvm.asc"

# 一時的なキーリングに取り込み、期待するフィンガープリントの鍵だけを書き出す。
# ファイルに別の鍵が含まれていても、それは登録しない
export GNUPGHOME="${tmp}/gnupg"
mkdir -m 700 "${GNUPGHOME}"
gpg --batch --quiet --import "${tmp}/llvm.asc"
if ! gpg --batch --list-keys --with-colons "${LLVM_KEY_FINGERPRINT}" | grep -q "^fpr:::::::::${LLVM_KEY_FINGERPRINT}:"; then
    echo "期待するフィンガープリントの LLVM の署名鍵が見つからない: ${LLVM_KEY_FINGERPRINT}" >&2
    exit 1
fi
gpg --batch --export "${LLVM_KEY_FINGERPRINT}" | sudo tee "${keyring}" > /dev/null
echo "deb [signed-by=${keyring}] https://apt.llvm.org/${codename}/ llvm-toolchain-${codename}-${LLVM_VERSION} main" \
    | sudo tee "/etc/apt/sources.list.d/llvm-${LLVM_VERSION}.list" > /dev/null
sudo apt-get update
