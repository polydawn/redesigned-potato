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

reppl put hash  gcc-src   Oez-roS1_43a20jVb7RqtK0g2KbrU87Wd__B5N_rCnkplQZU8tY0Rk9hdiyUXzkb  --warehouse=http://ftp.gnu.org/gnu/gcc/gcc-6.2.0/gcc-6.2.0.tar.bz2
reppl put hash  mpfr-src  IHIFTbYhG9Vtrey51vNrJcDcNRRN3HbXCTevp8l65vHqVWps3tJVHNS6WPqLUXvq  --warehouse=http://www.mpfr.org/mpfr-3.1.4/mpfr-3.1.4.tar.xz
reppl put hash  gmp-src   mbO3LDXQDhJZvH9hKPUFYbidQc9tI8qkSqVvstJWGfdT4S3u6y2mDboltFVNjYKY  --warehouse=http://ftp.gnu.org/gnu/gmp/gmp-6.1.1.tar.xz
reppl put hash  mpc-src   WfzjtnEfTaA-NaczWSMymCVxH8ydkaUa44wlfbilZnBt_H9KNaXq4zChZJ7qFdiQ  --warehouse=http://www.multiprecision.org/mpc/download/mpc-1.0.3.tar.gz
reppl eval lfs-002-gcc.frm

reppl put hash  kernel-src  gFPeFwgxUTG_1wkAcvQhLLK0KE_kXlVzve7VOAJiIdF70Khrpb28aVVIPoDWPUEo  --warehouse=https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.7.2.tar.xz
reppl eval lfs-003-kernelheaders.frm

reppl put hash glibc-src  EuSaUYVTHP-qIzxgY2vDdArjzitbFQQ8G-YDe2_dZU48zGd0seLcBpb6kGElk62Z --warehouse=http://ftp.gnu.org/gnu/glibc/glibc-2.24.tar.xz
reppl eval lfs-004-glibc.frm
