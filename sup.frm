inputs:
	"/":
		type: "tar"
		tag:  "ubuntu-base+gcc"
		silo:
			- "file+ca://./wares"
			- "http+ca://repeatr.s3.amazonaws.com/assets/"
	"/task/src/gcc":
		type: "tar"
		hash: "r3BCHaK3I4JUQcOttPvV6MjuKleytKuuOwWcOp3f-xj2exkRvJu_p3WdjuuY9Wyo"
		silo: "https://ftp.gnu.org/gnu/gcc/gcc-4.9.3/gcc-4.9.3.tar.bz2"
	"/task/src/mpfr":
		type: "tar"
		hash: "XOE2UW3gt8zDeip2lbS1o2QnHKjtTKMbdUMqBygHAssrk81hgJ74Ss2dicOzokyd"
		silo: "https://ftp.gnu.org/gnu/mpfr/mpfr-3.0.1.tar.bz2"
	"/task/src/gmp":
		type: "tar"
		hash: "vFbHn-XDgPRKI2j6aYXonaviCd-TBdaH3GdvyC-Tj04Ys0LTc_bqlBgERe5Gmllu"
		silo: "https://ftp.gnu.org/gnu/gmp/gmp-5.0.2.tar.bz2"
	"/task/src/mpc":
		type: "tar"
		hash: "WfzjtnEfTaA-NaczWSMymCVxH8ydkaUa44wlfbilZnBt_H9KNaXq4zChZJ7qFdiQ"
		silo: "https://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz"
action:
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
			echo bitches aint
			set -euo pipefail
			set -x

			gccSrcPath=/task/src/gcc/gcc-4.9.3/
			mkdir /yield
			cd /yield

			params=()
			params+=("--prefix=/task/target")
			params+=("--mandir=/task/target/doc/man")
			params+=("--infodir=/task/target/doc/info")

			# minimum viable libraries (as sources)
			# ... jk, just move them into a location where gcc picks them up, otherwise we have to separately compile these
			#params+=("--with-gmp=/task/src/gmp/gmp-5.0.2/")
			#params+=("--with-mpfr=/task/src/mpfr/mpfr-3.0.1/")
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
