## Test that this all works so far!
##  This is the test drive suggested at the end of http://www.linuxfromscratch.org/lfs/view/stable/chapter05/glibc.html
## Note that we're using a rootfs that does *not* include compilers here.
inputs:
	"/":
		type: "tar"
		tag:  "ubuntu-base"
		silo:
			- "file+ca://wares/"
			- "http+ca://repeatr.s3.amazonaws.com/assets/"
	"/lfs":
		type: "tar"
		tag:  "???"
		silo: "file+ca://wares/"
action:
	policy: governor
	env:
		"LFS":       "/lfs/"
		"PATH":      "/tools/bin:/bin:/usr/bin"
		"LFS_TGT":   "x86_64-lfs-linux-gnu"
	command:
		- "/bin/bash"
		- "-c"
		- |
			set -euo pipefail ; set -x
			ln -s $LFS/tools/ /

			echo 'int main(){}' > dummy.c
			$LFS_TGT-gcc dummy.c
			readelf -l a.out | grep ': /tools'
