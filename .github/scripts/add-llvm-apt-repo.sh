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
actual="$(gpg --show-keys --with-colons "${tmp}/llvm.asc" | awk -F: '$1 == "fpr" { print $10; exit }')"
if [[ "${actual}" != "${LLVM_KEY_FINGERPRINT}" ]]; then
    echo "LLVM の署名鍵のフィンガープリントが一致しない: ${actual}" >&2
    exit 1
fi

gpg --dearmor < "${tmp}/llvm.asc" | sudo tee "${keyring}" > /dev/null
echo "deb [signed-by=${keyring}] https://apt.llvm.org/${codename}/ llvm-toolchain-${codename}-${LLVM_VERSION} main" \
    | sudo tee "/etc/apt/sources.list.d/llvm-${LLVM_VERSION}.list" > /dev/null
sudo apt-get update
