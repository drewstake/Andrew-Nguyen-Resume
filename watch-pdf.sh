#!/usr/bin/env bash
set -u

cd "$(dirname "$0")"

open_pdf=false

if [ "${1:-}" = "--open" ]; then
  open_pdf=true
  shift
fi

tex_file="${1:-resume.tex}"
pdf_file="${tex_file%.tex}.pdf"

build_pdf() {
  printf '\n[%s] Building %s...\n' "$(date '+%H:%M:%S')" "$tex_file"
  if tectonic "$tex_file"; then
    printf '[%s] Updated %s\n' "$(date '+%H:%M:%S')" "$pdf_file"
  else
    printf '[%s] Build failed; keeping the last good PDF.\n' "$(date '+%H:%M:%S')"
  fi
}

if [ ! -f "$tex_file" ]; then
  printf 'Missing input file: %s\n' "$tex_file" >&2
  exit 1
fi

build_pdf

if [ "$open_pdf" = true ]; then
  open "$pdf_file"
fi

last_mtime="$(stat -f '%m' "$tex_file")"

printf 'Watching %s. Press Ctrl+C to stop.\n' "$tex_file"
printf 'Open %s once in Preview, then leave this watcher running.\n' "$pdf_file"
while true; do
  sleep 1
  current_mtime="$(stat -f '%m' "$tex_file")"

  if [ "$current_mtime" != "$last_mtime" ]; then
    last_mtime="$current_mtime"
    build_pdf
  fi
done
