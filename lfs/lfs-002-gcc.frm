## gcc
## http://www.linuxfromscratch.org/lfs/view/stable/chapter05/gcc-pass1.html
inputs:
        "/":           {tag: "ubuntu+lfs-deps"}
        "/lfs/tools":  {tag: "lfs-001-binutils"}
        "/src/gcc":    {tag: "gcc-src"}
        "/src/mpfr":   {tag: "mpfr-src"}
        "/src/gmp":    {tag: "gmp-src"}
        "/src/mpc":    {tag: "mpc-src"}
action:
        policy: governor
        env:
                "LFS":       "/lfs/"
                "LC_ALL":    "POSIX"
                "LFS_TGT":   "x86_64-lfs-linux-gnu"
                "PATH":      "/tools/bin:/usr/local/bin:/bin:/usr/bin"
                "MAKEFLAGS": "-j 8"
        cwd: "/src/gcc"
        command:
                - "/bin/bash"
                - "-c"
                - |
                        set -euo pipefail ; set -x
                        ln -s $LFS/tools /
                        cd gcc-*
                        cp -r /src/mpfr/mpfr-* mpfr
                        cp -r /src/gmp/gmp-* gmp
                        cp -r /src/mpc/mpc-* mpc

                        ## "The following command will change the location of GCC's default dynamic linker to use the one installed in /tools.
                        ## It also removes /usr/include from GCC's include search path."
                        for file in \
                         $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
                        do
                          cp -uv $file{,.orig}
                          sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
                              -e 's@/usr@/tools@g' $file.orig > $file
                          echo '
                        #undef STANDARD_STARTFILE_PREFIX_1
                        #undef STANDARD_STARTFILE_PREFIX_2
                        #define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
                        #define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
                          touch $file.orig
                        done

                        mkdir -v build; cd build
                        time {
                                ../configure \
                                    --target=$LFS_TGT                              \
                                    --prefix=/tools                                \
                                    --with-glibc-version=2.11                      \
                                    --with-sysroot=$LFS                            \
                                    --with-newlib                                  \
                                    --without-headers                              \
                                    --with-local-prefix=/tools                     \
                                    --with-native-system-header-dir=/tools/include \
                                    --disable-nls                                  \
                                    --disable-shared                               \
                                    --disable-multilib                             \
                                    --disable-decimal-float                        \
                                    --disable-threads                              \
                                    --disable-libatomic                            \
                                    --disable-libgomp                              \
                                    --disable-libmpx                               \
                                    --disable-libquadmath                          \
                                    --disable-libssp                               \
                                    --disable-libvtv                               \
                                    --disable-libstdcxx                            \
                                    --enable-languages=c,c++
                                make
                                make install
                        }
outputs:
        "tools":
                mount: "/lfs/tools"
                tag: "lfs-002-gcc"
                type: "tar"
                silo: "file+ca://wares/"
        "debug":
                mount: "/lfs"
                type: "dir"
                silo: "file://debug/002-gcc"
        "debug2":
                mount: "/src/gcc"
                type: "dir"
                silo: "file://debug/002-gcc-build"
