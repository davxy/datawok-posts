#!/usr/bin/env bash

if [[ $1 == "" ]]; then
  echo "Usage: $0 <file>"
  exit
fi

current_date=$(date '+%Y-%m-%d')

tmp="$(mktemp)"

# Construct the best title we can afford
title=$(cat $1 | grep -m1 "#" | sed 's/^[#[:space:]]*//;s/[[:space:]]*$//')

cat << EOF > "$tmp"
+++
title = "$title"
date = "$current_date"
tags = ["draft"]
draft = true
toc = true
+++

EOF

cat "$1" >> "$tmp"

mv "$tmp" "$1"
