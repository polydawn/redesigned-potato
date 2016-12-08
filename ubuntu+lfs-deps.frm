inputs:
        "/":
                type: "tar"
                tag:  "ubuntu-base"
                silo:
                        - "file+ca://./wares"
                        - "http+ca://repeatr.s3.amazonaws.com/assets/"
        "/task/src/gcc":
                type: "tar"
                hash: "Oez-roS1_43a20jVb7RqtK0g2KbrU87Wd__B5N_rCnkplQZU8tY0Rk9hdiyUXzkb"
                silo: "https://ftp.gnu.org/gnu/gcc/gcc-6.2.0/gcc-6.2.0.tar.gz"
        "/task/src/mpfr":
                type: "tar"
                hash: "zDDUnHejvCr6AOuxeJHXgG4tDtvB6_tVpmC8aIQFSsQmYBokgJxXtb2TeWdul9yZ"
                silo: "https://ftp.gnu.org/gnu/mpfr/mpfr-3.1.5.tar.gz"
        "/task/src/gmp":
                type: "tar"
                hash: "mbO3LDXQDhJZvH9hKPUFYbidQc9tI8qkSqVvstJWGfdT4S3u6y2mDboltFVNjYKY"
                silo: "https://ftp.gnu.org/gnu/gmp/gmp-6.1.1.tar.bz2"
        "/task/src/mpc":
                type: "tar"
                hash: "WfzjtnEfTaA-NaczWSMymCVxH8ydkaUa44wlfbilZnBt_H9KNaXq4zChZJ7qFdiQ"
                silo: "https://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz"
action:
        policy: "governor"
        command:
                - "/bin/bash"
                - "-c"
                - |
                        #!/bin/bash
                        set -euo pipefail
                        
                        apt-get update

                        # LFS dependancy tools from http://www.linuxfromscratch.org/lfs/view/stable/chapter02/hostreqs.html
                        apt-get install -y binutils bison bzip2 coreutils diffutils findutils gawk gcc g++ grep gzip m4 make patch perl sed tar texinfo xz-utils autoconf

                        # /bin/sh should be bash, not dash
                        rm /bin/sh
                        ln -s /bin/bash /bin/sh

                        # install a newer automake, needed by GCC build
                        function install_automake() {
                            [ $# -eq 0 ] && { run_error "Usage: install_automake <version>"; exit; }
                            local VERSION=${1}
                            wget ftp://ftp.gnu.org/gnu/automake/automake-${VERSION}.tar.gz &> /dev/null
                            if [ -f "automake-${VERSION}.tar.gz" ]; then
                                    tar -xzf automake-${VERSION}.tar.gz
                                    cd automake-${VERSION}/
                                    ./configure
                                    make && make install
                                    echo -e "\e[1;39m[   \e[1;32mOK\e[39m   ] automake-${VERSION} installed\e[0;39m"

                                else
                                    echo -e "\e[1;39m[   \e[31mError\e[39m   ] cannot fetch file from ftp://ftp.gnu.org/gnu/automake/ \e[0;39m"
                                    exit 1
                            fi
                        }

                        install_automake 1.15
                        which automake
                        automake --version
                        
                        # Simple script to list version numbers of critical development tools
                        # borrowed from http://www.linuxfromscratch.org/lfs/view/stable/chapter02/hostreqs.html
                        export LC_ALL=C
                        bash --version | head -n1 | cut -d" " -f2-4
                        MYSH=$(readlink -f /bin/sh)
                        echo "/bin/sh -> $MYSH"
                        echo $MYSH | grep -q bash || echo "ERROR: /bin/sh does not point to bash"
                        unset MYSH

                        echo -n "Binutils: "; ld --version | head -n1 | cut -d" " -f3-
                        bison --version | head -n1

                        if [ -h /usr/bin/yacc ]; then
                          echo "/usr/bin/yacc -> `readlink -f /usr/bin/yacc`";
                        elif [ -x /usr/bin/yacc ]; then
                          echo yacc is `/usr/bin/yacc --version | head -n1`
                        else
                          echo "yacc not found" 
                        fi

                        bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f1,6-
                        echo -n "Coreutils: "; chown --version | head -n1 | cut -d")" -f2
                        diff --version | head -n1
                        find --version | head -n1
                        gawk --version | head -n1

                        if [ -h /usr/bin/awk ]; then
                          echo "/usr/bin/awk -> `readlink -f /usr/bin/awk`";
                        elif [ -x /usr/bin/awk ]; then
                          echo awk is `/usr/bin/awk --version | head -n1`
                        else 
                          echo "awk not found" 
                        fi

                        gcc --version | head -n1
                        g++ --version | head -n1
                        ldd --version | head -n1 | cut -d" " -f2-  # glibc version
                        grep --version | head -n1
                        gzip --version | head -n1
                        cat /proc/version
                        m4 --version | head -n1
                        make --version | head -n1
                        patch --version | head -n1
                        echo Perl `perl -V:version`
                        sed --version | head -n1
                        tar --version | head -n1
                        makeinfo --version | head -n1
                        xz --version | head -n1

                        echo 'int main(){}' > dummy.c && g++ -o dummy dummy.c
                        if [ -x dummy ]
                          then echo "g++ compilation OK";
                          else echo "g++ compilation failed"; fi
                        rm -f dummy.c dummy

                        for lib in lib{gmp,mpfr,mpc}.la; do
                          echo $lib: $(if find /usr/lib* -name $lib|
                                       grep -q $lib;then :;else echo not;fi) found
                        done
                        unset lib

outputs:
        "ubuntu+lfs-deps":
                tag: "ubuntu+lfs-deps"
                type: "tar"
                mount: "/"
                silo: "file+ca://./wares"
