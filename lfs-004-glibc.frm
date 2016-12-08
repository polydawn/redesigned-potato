## Glibc!
##  http://www.linuxfromscratch.org/lfs/view/stable/chapter05/glibc.html
inputs:
        "/":
                type: "tar"
                tag:  "ubuntu+lfs-deps"
                silo:
                        - "file+ca://wares/"
        "/src/glibc":
                type: "tar"
                hash: "EuSaUYVTHP-qIzxgY2vDdArjzitbFQQ8G-YDe2_dZU48zGd0seLcBpb6kGElk62Z"
                silo: "http://ftp.gnu.org/gnu/glibc/glibc-2.24.tar.xz"
        "/lfs/tools":
                type: "tar"
                tag:  "lfs-003-kernelheaders"
                silo: "file+ca://wares/"
action:
        policy: governor
        env:
                "LFS":       "/lfs/"
                "LC_ALL":    "POSIX"
                "LFS_TGT":   "x86_64-lfs-linux-gnu"
                "PATH":      "/tools/bin:/bin:/usr/bin"
                "MAKEFLAGS": "-j 8"
        cwd: "/src/glibc"
        command:
                - "/bin/bash"
                - "-c"
                - |
                        set -euo pipefail ; set -x
                        ln -s $LFS/tools/ /
                        cd *
                        mkdir -v build; cd build
                        time {
                                ../configure \
                                  --prefix=/tools                    \
                                  --host=$LFS_TGT                    \
                                  --build=$(../scripts/config.guess) \
                                  --enable-kernel=2.6.32             \
                                  --with-headers=/tools/include      \
                                  libc_cv_forced_unwind=yes          \
                                  libc_cv_c_cleanup=yes
                                make
                                make install
                        }
outputs:
        "tools":
                mount: "/lfs/tools"
                tag: "lfs-004-glibc"
                type: "tar"
                silo: "file+ca://wares/"
        "debug":
                mount: "/lfs"
                type: "dir"
                silo: "file://debug/003-kernelheaders"
