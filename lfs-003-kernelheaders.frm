## Unpack kernel headers.
##  http://www.linuxfromscratch.org/lfs/view/stable/chapter05/linux-headers.html
inputs:
	"/":
		type: "tar"
		tag:  "ubuntu-base+gcc"
		silo:
			- "file+ca://wares/"
			- "http+ca://repeatr.s3.amazonaws.com/assets/"
	"/src/kernel":
		type: "tar"
		hash: "gFPeFwgxUTG_1wkAcvQhLLK0KE_kXlVzve7VOAJiIdF70Khrpb28aVVIPoDWPUEo"
		silo: "https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.7.2.tar.xz"
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
