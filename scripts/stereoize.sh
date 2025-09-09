#!/usr/bin/env bash
# stereoize.sh — Dry-run by default; use --apply to actually modify files
# 2025-09-07

set -euo pipefail

ROOT="${1:-.}"
APPLY="${2:-}"
DRY_RUN=1
[[ "${APPLY}" == "--apply" ]] && DRY_RUN=0

log() { printf '%s\n' "$*"; }

# Has at least one audio stream?
is_audio() {
  ffprobe -v error -select_streams a -show_entries stream=codec_type \
    -of default=noprint_wrappers=1:nokey=1 -- "$1" 2>/dev/null | grep -q '^audio$'
}

# Channels in first audio stream: prints "1", "2", … or empty on failure
audio_channels() {
  ffprobe -v error -select_streams a:0 -show_entries stream=channels \
    -of default=noprint_wrappers=1:nokey=1 -- "$1" 2>/dev/null | tr -d '[:space:]'
}

# Replace spaces/specials with "_", collapse repeats, trim edges.
# Guarantees a non-empty basename; preserves extension if present.
sanitize_basename() {
  local base="${1:-}"
  local name ext
  if [[ -z "$base" ]]; then
    printf 'unnamed'
    return
  fi
  name="${base%.*}"
  ext="${base##*.}"
  if [[ "$ext" == "$base" ]]; then ext=""; fi

  name="$(printf '%s' "$name" | sed -E 's/[^A-Za-z0-9._-]+/_/g; s/_+/_/g; s/^_+//; s/_+$//')"
  if [[ -z "$name" ]]; then name="unnamed"; fi

  if [[ -n "$ext" ]]; then
    printf '%s.%s' "$name" "$ext"
  else
    printf '%s' "$name"
  fi
}

# Pick a unique path by appending _1, _2, …
unique_path() {
  local target="${1-}"
  if [[ -z "${target:-}" ]]; then
    # Return empty to signal "no valid target"
    printf ''
    return 1
  fi
  local try="$target" n=1
  while [[ -e "$try" ]]; do
    local dir base stem ext
    dir="$(dirname -- "$target")"
    base="$(basename -- "$target")"
    stem="${base%.*}"
    ext="${base##*.}"
    if [[ "$ext" == "$base" ]]; then
      try="${dir}/${stem}_$n"
    else
      try="${dir}/${stem}_$n.${ext}"
    fi
    ((n++))
  done
  printf '%s' "$try"
}

# Convert mono → stereo in place (temp file then move back)
# replace your existing convert_mono_to_stereo() with this
convert_mono_to_stereo() {
  local file ext tmp fmt
  file="$1"
  ext="${file##*.}"
  ext_lower="$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')" # portable lowercase
  tmp="${file%.*}.tmp.${ext}"

  # For container types where ffmpeg guesses badly, be explicit
  case "$ext_lower" in
  wav) fmt='-f wav' ;;
  aif | aiff) fmt='-f aiff' ;;
  caf) fmt='-f caf' ;;
  *) fmt='' ;;
  esac

  ffmpeg -y -i "$file" -map 0 \
    -filter:a:0 aformat=channel_layouts=stereo -ac 2 \
    -map_metadata 0 \
    -c:v copy $fmt -- "$tmp"

  mv -f -- "$tmp" "$file"
}

# Walk all files (we examine *everything* so we can delete non-audio too)
find "$ROOT" -type f -print0 | while IFS= read -r -d '' path; do
  dir="$(dirname -- "$path")"
  base="$(basename -- "$path")"

  # 1) Filename sanitize (not directories)
  sanitized="$(sanitize_basename "$base")"
  new_path="$path"
  if [[ "$sanitized" != "$base" ]]; then
    candidate="${dir}/${sanitized}"
    if new_candidate="$(unique_path "$candidate")"; then
      if [[ $DRY_RUN -eq 1 ]]; then
        log "[DRY-RUN] Would rename: $path -> $new_candidate"
      else
        log "Renaming: $path -> $new_candidate"
        mv -f -- "$path" "$new_candidate"
      fi
      new_path="$new_candidate"
    else
      log "Skipping rename (no valid target): $path"
    fi
  fi

  # Operate on the possibly-renamed path
  path="$new_path"

  # 2) Delete non-audio
  if ! is_audio "$path"; then
    if [[ $DRY_RUN -eq 1 ]]; then
      log "[DRY-RUN] Would delete non-audio: $path"
    else
      log "Deleting non-audio: $path"
      rm -f -- "$path"
    fi
    continue
  fi

  # 3) Convert mono → stereo (in place, no name change)
  channels="$(audio_channels "$path" || true)"
  if [[ "$channels" == "1" ]]; then
    if [[ $DRY_RUN -eq 1 ]]; then
      log "[DRY-RUN] Would convert mono -> stereo: $path"
    else
      log "Converting mono -> stereo: $path"
      convert_mono_to_stereo "$path"
      log "Done: $path"
    fi
  fi
done
