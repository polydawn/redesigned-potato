inputs:
	"/":
		type: "tar"
		tag:  "ubuntu-base"
		silo:
			- "file+ca://wares/"
			- "http+ca://repeatr.s3.amazonaws.com/assets/"
action:
	policy: governor
	command:
		- "/bin/bash"
		- "-c"
		- |
			set -euo pipefail ; set -x
			mkdir /output
			echo "wheeeee asset A" > /output/wow
outputs:
	"asset-A":
		mount: "/output"
		type: "tar"
		silo: "file+ca://wares/"
		tag: "asset-A"
