## Unpack kernel headers.
##  http://www.linuxfromscratch.org/lfs/view/stable/chapter05/linux-headers.html
inputs:
        "/":            {tag: "ubuntu+lfs-deps"}
        "/src/kernel":  {tag: "kernel-src"}
        "/lfs/tools":   {tag: "lfs-002-gcc"}
action:
        policy: governor
        env:
                "LFS":       "/lfs/"
                "LC_ALL":    "POSIX"
                "LFS_TGT":   "x86_64-lfs-linux-gnu"
                "PATH":      "/tools/bin:/bin:/usr/bin"
                "MAKEFLAGS": "-j 8"
        cwd: "/src/kernel"
        command:
                - "/bin/bash"
                - "-c"
                - |
                        set -euo pipefail ; set -x
                        ln -s $LFS/tools/ /
                        cd *
                        make mrproper
                        make INSTALL_HDR_PATH=dest headers_install
                        cp -rv dest/include/* /$LFS/tools/include
outputs:
        "tools":
                mount: "/lfs/tools"
                tag: "lfs-003-kernelheaders"
                type: "tar"
                silo: "file+ca://wares/"
        "debug":
                mount: "/lfs"
                type: "dir"
                silo: "file://debug/003-kernelheaders"
