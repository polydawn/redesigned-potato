## Binutils
## http://www.linuxfromscratch.org/lfs/view/stable/chapter05/binutils-pass1.html
inputs:
	"/":
		type: "tar"
		tag:  "ubuntu+lfs-deps"
		silo:
			- "file+ca://wares/"
			- "http+ca://repeatr.s3.amazonaws.com/assets/"
	"/src/binutils":
		type: "tar"
		hash: "m2-ZAxYvz_XMuWPj0lay3vsxf-pmrghkLQUeG83JzJfEg8eZ3d4q17eqq1Z5OGdY"
		silo: "http://ftp.gnu.org/gnu/binutils/binutils-2.27.tar.bz2"
action:
	policy: governor
	env:
		"LFS":       "/lfs/"
		"LC_ALL":    "POSIX"
		"LFS_TGT":   "x86_64-lfs-linux-gnu"
		"PATH":      "/tools/bin:/bin:/usr/bin"
		"MAKEFLAGS": "-j 8"
	cwd: "/src/binutils"
	command:
		- "/bin/bash"
		- "-c"
		- |
			set -euo pipefail ; set -x
			mkdir -p $LFS/tools
			ln -s $LFS/tools /
			cd *
			mkdir -v build; cd build
			time {
				../configure \
				  --prefix=/tools        	  \
				  --with-sysroot=$LFS        	  \
				  --with-lib-path=/tools/lib      \
				  --target=$LFS_TGT          	  \
				  --disable-nls              	  \
				  --disable-werror
				make
				mkdir -v /tools/lib && ln -sv lib /tools/lib64
				make install
			}
outputs:
	"all":
		mount: "/lfs/tools"
		type: "tar"
		silo: "file+ca://wares/"
		tag: "lfs-001-binutils"
	"debug":
		mount: "/lfs"
		type: "dir"
		silo: "file://debug/lfs-001"
