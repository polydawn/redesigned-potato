inputs:
	"/":
		type: "tar"
		tag:  "ubuntu-base+gcc"
		silo:
			- "file+ca://wares/"
			- "http+ca://repeatr.s3.amazonaws.com/assets/"
action:
	env:
		"LFS": "/yield/lfs"
	command:
		- "/bin/bash"
		- "-c"
		- |
			set -euo pipefail ; set -x
