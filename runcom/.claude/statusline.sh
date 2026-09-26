#!/bin/bash
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')
[ -n "$cwd" ] && cwd="${cwd/#$HOME/\~}"

branch=""
if [ -n "$cwd" ] && git -C "${cwd/#\~/$HOME}" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "${cwd/#\~/$HOME}" --no-optional-locks branch --show-current 2>/dev/null)
fi

# "Opus 5.5 (1M context)" -> "Opus 5.5 [1m]"
model=$(echo "$input" | jq -r '.model.display_name // empty')
if [[ "$model" == *"(1M context)"* ]]; then
  model="${model/ (1M context)/} [1m]"
fi
effort=$(echo "$input" | jq -r '.effort.level // empty')

used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

line1="$model"
[ -n "$effort" ] && line1="$line1 $effort"
if [ -n "$used" ]; then
  line1="$line1 | ctx: $(printf '%.0f' "$used")% used"
  [ -n "$remaining" ] && line1="$line1 ($(printf '%.0f' "$remaining")% left)"
fi

# Time until an epoch-seconds reset, e.g. "2h13m" or "1d3h".
until_reset() {
  local s=$(( $1 - $(date +%s) ))
  (( s < 0 )) && s=0
  local d=$(( s / 86400 )) h=$(( s % 86400 / 3600 )) m=$(( s % 3600 / 60 ))
  if (( d > 0 )); then echo "${d}d${h}h"
  elif (( h > 0 )); then echo "${h}h${m}m"
  else echo "${m}m"
  fi
}

for win in five_hour:5h seven_day:7d; do
  key=${win%%:*} label=${win##*:}
  pct=$(echo "$input" | jq -r ".rate_limits.$key.used_percentage // empty")
  reset=$(echo "$input" | jq -r ".rate_limits.$key.resets_at // empty")
  [ -z "$pct" ] && continue
  seg="$label: $(printf '%.0f' "$pct")% used"
  [ -n "$reset" ] && seg="$seg (resets in $(until_reset "$reset"))"
  line1="$line1 | $seg"
done

line2="$cwd"
[ -n "$branch" ] && line2="$line2 ($branch)"

printf '%s\n%s\n' "$line1" "$line2"
