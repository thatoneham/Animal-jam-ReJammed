#!/bin/sh
echo -ne '\033c\033]0;Animal Jam Godot\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/AJCReJammed.x86_64" "$@"
