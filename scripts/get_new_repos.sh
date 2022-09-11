#!/usr/bin/env bash
set -ue

date_range=$(date --date="3 day ago" +"%Y-%m-%d")
gh api --method=GET search/repositories -f q="nvim created:>$date_range sort:updated" -f per_page=100 >/tmp/repo.json
cat /tmp/repo.json | jq -r '.items[] | select(.full_name | test("/nvim-") or endswith(".nvim")) |
  select(.full_name | test("/nvim-config") or test("/nvim-conf") or endswith("/nvim") or test("theme") | not) |
  select(.language != "Vim Script") |
  select(contains({description: "colorscheme"}) or contains({description: "config"}) | not) |
  select(.topics | index("neovim-colorscheme") or index("neovim-theme") or index("colorscheme") or index("dotfiles") | not)
  .full_name' >/tmp/repo2.txt
if [[ -e /tmp/repo.3.txt ]]; then
	rm /tmp/repo3.txt
fi
cat /tmp/repo2.txt | xargs -i bash -c "gh api user/starred/{} >/dev/null 2>&1 || echo {} >> /tmp/repo3.txt"
