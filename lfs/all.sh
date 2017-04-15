#!/bin/bash
set -euo pipefail

cd "$( dirname "${BASH_SOURCE[0]}" )"

mkdir -p wares
mkdir -p debug
reppl put hash ubuntu-base aLMH4qK1EdlPDavdhErOs0BPxqO0i6lUaeRE4DuUmnNMxhHtF56gkoeSulvwWNqT
reppl eval ubuntu+lfs-deps.frm
reppl eval lfs-001-binutils.frm
reppl eval lfs-002-gcc.frm
reppl eval lfs-003-kernelheaders.frm
reppl eval lfs-004-glibc.frm
