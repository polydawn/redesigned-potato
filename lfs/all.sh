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

reppl put hash  gcc-src   SpHcPlhbJ5OsFtI7iSxAMfsfozjtdsJ48yXlzON3mdtE5nubgV1GHW5tcE-Z1RZm  --warehouse=http://ftp.gnu.org/gnu/gcc/gcc-6.3.0/gcc-6.3.0.tar.bz2
reppl put hash  mpfr-src  zDDUnHejvCr6AOuxeJHXgG4tDtvB6_tVpmC8aIQFSsQmYBokgJxXtb2TeWdul9yZ  --warehouse=http://www.mpfr.org/mpfr-3.1.5/mpfr-3.1.5.tar.xz
reppl put hash  gmp-src   W-SNS08o6r69NO0Gf3ydylWaMO64_A88s91erg7xr8KSwr8BrW39j-XdOPmqFDr8  --warehouse=http://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.xz
reppl put hash  mpc-src   WfzjtnEfTaA-NaczWSMymCVxH8ydkaUa44wlfbilZnBt_H9KNaXq4zChZJ7qFdiQ  --warehouse=http://www.multiprecision.org/mpc/download/mpc-1.0.3.tar.gz
reppl eval lfs-002-gcc.frm

reppl put hash  kernel-src  oQ-G18xgeR0mXhb2pu7VieCt_cBUsQOpqewpRTE8pnimFZygKsOaA7qNJzWaL-Oa  --warehouse=https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.9.9.tar.xz
reppl eval lfs-003-kernelheaders.frm

reppl put hash  glibc-src  eSqmNRsnFdVR-AYY4e_BdIxI7Vs7iwLkoAREm8O1BPiVqn_fPd-fDTP_kwsHPpgY --warehouse=http://ftp.gnu.org/gnu/glibc/glibc-2.25.tar.xz
reppl eval lfs-004-glibc.frm

reppl eval lfs-005-test.frm
