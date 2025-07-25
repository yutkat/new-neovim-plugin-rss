#!/usr/bin/env bash
set -ue

date_range_from=$(date --date="3 day ago" +"%Y-%m-%d")
date_range_to=$(date --date="2 day ago" +"%Y-%m-%d")

if [[ -e /tmp/repo.json ]]; then
  rm /tmp/repo.json
fi

page=1
while :; do
  result=$(gh api --method=GET search/repositories -f q="nvim created:${date_range_from}..${date_range_to} sort:updated" -f per_page=100 -f page=$page | tee -a /tmp/repo.json)
  page=$((page + 1))
  items=$(echo $result | jq -r '.items[]')
  [ -z "$items" ] && break
done

cat /tmp/repo.json | jq -r '.items[] | select(.full_name | test("/nvim-") or endswith(".nvim")) |
		select(.full_name | test("/nvim-config") or
			test("/nvim-conf") or
			test("/nvim-ide") or
			test("/nvim-basic-ide") or
			test("/nvim-ide-basic") or
			test("/nvim-from-scratch") or
			endswith("/nvim") or
			endswith("/nvim-setup") or
			endswith("/nvim-lua") or
			endswith("/.nvim") or
			endswith("/nvim-lazy") or
                        endswith("/stackmap.nvim") or
			endswith("/present.nvim") or
			test("dotfiles") or
			contains("dots") or
			contains("init") | not) |
		select(.size != 0) |
		select(.language != "Vim Script") |
		select(contains({description: "colorscheme"}) or contains({description: "config"}) | not) |
		select(.topics | index("neovim-colorscheme") or index("neovim-theme") or index("colorscheme") or index("dotfiles") | not)
.full_name' > /tmp/repo2.txt

cat /tmp/repo2.txt | xargs -i bash -c "gh api /user/starred/{} >/dev/null 2>&1 || echo {}" > /tmp/repo3.txt
cat /tmp/repo3.txt | xargs -i bash -c "gh api /repos/{}/readme >/dev/null 2>&1 && echo {} || true" > /tmp/repo4.txt
cat /tmp/repo4.txt | xargs -i bash -c "gh api /repos/{}/contents/lua >/dev/null 2>&1 && echo {} || true" > /tmp/repo5.txt
cat /tmp/repo4.txt | xargs -i bash -c "gh api /repos/{}/contents/plugin >/dev/null 2>&1 && echo {} || true" >> /tmp/repo5.txt
cat /tmp/repo5.txt | xargs -i bash -c "gh api /repos/{}/contents/lua/plugin_name.lua >/dev/null 2>&1 || echo {}" > /tmp/repo6.txt
cat /tmp/repo6.txt | xargs -i bash -c "gh api /repos/{}/contents/colors >/dev/null 2>&1 || echo {}" > /tmp/repo7.txt
cat /tmp/repo7.txt | xargs -i bash -c "gh api /repos/{}/contributors | jq -e 'length < 3' >/dev/null && echo {}" > /tmp/repo8.txt || true
cat /tmp/repo8.txt | xargs -i bash -c "gh api /repos/{}/contents/init.lua >/dev/null 2>&1 || echo {}" > /tmp/new_repos.txt
cat /tmp/new_repos.txt
