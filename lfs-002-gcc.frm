## gcc
## http://www.linuxfromscratch.org/lfs/view/stable/chapter05/gcc-pass1.html
inputs:
        "/":
                type: "tar"
                tag:  "ubuntu+lfs-deps"
                silo: "file+ca://wares/"
        "/lfs/tools":
                type: "tar"
                tag:  "lfs-001-binutils"
                silo: "file+ca://wares/"
        "/src/gcc":
                type: "tar"
                hash: "Oez-roS1_43a20jVb7RqtK0g2KbrU87Wd__B5N_rCnkplQZU8tY0Rk9hdiyUXzkb"
                silo: "http://ftp.gnu.org/gnu/gcc/gcc-6.2.0/gcc-6.2.0.tar.bz2"
        "/src/mpfr":
                type: "tar"
                hash: "IHIFTbYhG9Vtrey51vNrJcDcNRRN3HbXCTevp8l65vHqVWps3tJVHNS6WPqLUXvq"
                silo: "http://www.mpfr.org/mpfr-3.1.4/mpfr-3.1.4.tar.xz"
        "/src/gmp":
                type: "tar"
                hash: "mbO3LDXQDhJZvH9hKPUFYbidQc9tI8qkSqVvstJWGfdT4S3u6y2mDboltFVNjYKY"
                silo: "http://ftp.gnu.org/gnu/gmp/gmp-6.1.1.tar.xz"
        "/src/mpc":
                type: "tar"
                hash: "WfzjtnEfTaA-NaczWSMymCVxH8ydkaUa44wlfbilZnBt_H9KNaXq4zChZJ7qFdiQ"
                silo: "http://www.multiprecision.org/mpc/download/mpc-1.0.3.tar.gz"
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
