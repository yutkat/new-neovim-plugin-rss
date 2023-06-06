#!/usr/bin/env bash
set -ue

if [[ ! -e /tmp/new_repos.txt ]]; then
	exit 0
fi

if [[ $(wc -l </tmp/new_repos.txt) -eq 0 ]]; then
	exit 0
fi

REPOS=($(cat /tmp/new_repos.txt | sed 's#/#--#g'))
DATE=$(date +"%Y-%m-%d")

for r in "${REPOS[@]}"; do
	if compgen -G ./_posts/????-??-??-$r.html >/dev/null; then
		continue
	fi
	repo=${r//--/\/}
	touch ./_posts/$DATE-$r.html
	tee ./_posts/$DATE-$r.html <<EOF >/dev/null
---
layout: default
title: $repo
---
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="refresh" content="0; url='https://github.com/$repo'" />
  </head>
  <body>
    <a href="https://github.com/$repo">$repo</a>
  </body>
</html>
EOF
	echo "Add: $repo"
done
