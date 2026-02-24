#!/bin/sh
printf '\033c\033]0;%s\a' godot_bubblebobbleclone_owenmarshall
base_path="$(dirname "$(realpath "$0")")"
"$base_path/godot_bubblebobbleclone_owenmarshall.x86_64" "$@"
