inputs:
	"/":
		type: "tar"
		tag:  "ubuntu-base+gcc"
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
		#
		# There are lots of interesting examples feeding into this script, since the
		# gcc docs themselves are... Real Helpful.  Really.  I swear.  Help.  Full.
		#
		# Actual sources of help:
		#   - http://git.alpinelinux.org/cgit/aports/tree/main/gcc/APKBUILD?id=61dd7a457049d16ed051eb2f693dca4950af469b
		#   - http://blog.rootserverexperiment.de/2011/07/02/cross-compiling-uclibc-and-busybox/
		#   - http://openwall.info/wiki/internal/gcc-local-build
		- |
			#!/bin/bash
			set -euo pipefail
			set -x
			
			apt-get update
			apt-get install -y automake texinfo libtool autoconf autogen

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

			gccSrcPath=/task/src/gcc/gcc-6.2.0/
			mkdir /yield
			cd /yield

			params=()
			params+=("--prefix=/task/target")
			params+=("--mandir=/task/target/doc/man")
			params+=("--infodir=/task/target/doc/info")

			# minimum viable libraries (as sources)
			# ... jk, just move them into a location where gcc picks them up, otherwise we have to separately compile these
			#params+=("--with-gmp=/task/src/gmp/gmp-6.1.1/")
			#params+=("--with-mpfr=/task/src/mpfr/mpfr-3.1.5/")
			#params+=("--with-mpc=/task/src/mpc/mpc-1.0.3")
			## Note: following could mv... if we fixed certain cradle issues.
			cp -r /task/src/gmp/*  $gccSrcPath/gmp
			cp -r /task/src/mpfr/* $gccSrcPath/mpfr
			cp -r /task/src/mpc/*  $gccSrcPath/mpc

			# skip lots of extensions
			# and whitelist languages
			params+=("--disable-multilib") # this is required
			params+=("--enable-languages=c,c++")
			params+=("--enable-static")
			params+=("--disable-shared")
			params+=("--disable-nls")
			params+=("--disable-libmudflap")
			params+=("--disable-libssp")
			params+=("--disable-libgomp")
			params+=("--disable-libquadmath")
			params+=("--disable-target-libiberty")
			params+=("--disable-target-zlib")
			params+=("--disable-decimal-float")
			params+=("--enable-threads")
			params+=("--enable-tls")
			params+=("--without-ppl")
			params+=("--without-cloog")

			# ???
			#params+=("--host=x86_64-alpine-linux-musl")
			#params+=("--target=x86_64-unknown-linux-gnu")

			$gccSrcPath/configure "${params[@]}" || \
				{
					set +e
					echo FAILED $?
					echo
					echo
					cat config.log
					echo
					echo
				}

			make -j8

			### it's very possible it's time to back up and do binutils

outputs:
	"gcc":
		tag: "gcc"
		type: "tar"
		mount: "/yield"
		silo: "file+ca://./wares"
