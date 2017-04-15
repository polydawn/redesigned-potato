#!/bin/bash
set -euo pipefail

cd "$( dirname "${BASH_SOURCE[0]}" )"

mkdir -p wares
mkdir -p debug

### Phase -1: "Host" image construction.
reppl put hash  ubuntu-base  aLMH4qK1EdlPDavdhErOs0BPxqO0i6lUaeRE4DuUmnNMxhHtF56gkoeSulvwWNqT  --warehouse=http+ca://repeatr.s3.amazonaws.com/assets/
reppl eval ubuntu+lfs-deps.frm

### Phase 0: building basics, the first time.
reppl put hash  binutils-src  m2-ZAxYvz_XMuWPj0lay3vsxf-pmrghkLQUeG83JzJfEg8eZ3d4q17eqq1Z5OGdY  --warehouse=http://ftp.gnu.org/gnu/binutils/binutils-2.27.tar.bz2
reppl eval lfs-001-binutils.frm
reppl eval lfs-002-gcc.frm
reppl eval lfs-003-kernelheaders.frm
reppl eval lfs-004-glibc.frm
