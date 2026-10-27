#!/usr/bin/env bash
set -e

BIN="$HOME/.local/bin"
ACTIONS="$HOME/.local/share/nemo/actions"
CONFIG="$HOME/.config/nemo-poster-downloader"

mkdir -p "$BIN" "$ACTIONS" "$CONFIG"

cat > "$BIN/folder_processor.sh" <<'SCRIPT'
#!/usr/bin/env bash

set -u
export LC_ALL=C.UTF-8

CONFIG_DIR="$HOME/.config/nemo-poster-downloader"
LOG_FILE="$CONFIG_DIR/processor.log"

mkdir -p "$CONFIG_DIR"
touch "$LOG_FILE"

log() {
    printf '[%s] %s\n' "$(date '+%F %T')" "$*" >> "$LOG_FILE"
}

for cmd in curl python3; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log "ERROR: Missing dependency: $cmd"
        exit 1
    fi
done

urlencode() {
    python3 -c 'import sys,urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip(),safe=""))' <<< "$1"
}

json_field() {
    python3 -c "$1" 2>/dev/null || true
}

fetch() {
    curl -fsSL --connect-timeout 5 --max-time 15 \
        --retry 1 --retry-delay 1 "$1" 2>/dev/null || true
}

# 1. MyAnimeList (Jikan API) - Anime search
jikan_poster() {
    local data
    data=$(fetch "https://api.jikan.moe/v4/anime?q=$(urlencode "$1")&limit=1")
    [[ -n "$data" ]] || return 0

    printf '%s' "$data" | json_field '
import json,sys
try:
 d=json.load(sys.stdin)
 a=d.get("data",[])
 if a:
  i=a[0].get("images",{})
  print(i.get("jpg",{}).get("large_image_url") or
        i.get("webp",{}).get("large_image_url") or "")
except Exception:
 pass
'
}

# 2. IMDb Direct Suggestion API - Movies & TV Shows search
imdb_poster() {
    local query_slug
    query_slug=$(python3 -c 'import sys,urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip().lower().replace(" ", "_"),safe=""))' <<< "$1")
    
    local first_char="${query_slug:0:1}"
    [[ -z "$first_char" ]] && first_char="a"

    local data
    data=$(fetch "https://v3.sg.media-imdb.com/suggestion/${first_char}/${query_slug}.json")
    [[ -n "$data" ]] || return 0

    printf '%s' "$data" | json_field '
import json,sys
try:
 d=json.load(sys.stdin)
 d_list=d.get("d",[])
 for item in d_list:
  i=item.get("i",{})
  u=i.get("imageUrl")
  if u:
   print(u)
   break
except Exception:
 pass
'
}

clean_name() {
    local n="$1"

    n="${n//./ }"
    n="${n//_/ }"

    n=$(printf '%s' "$n" | sed -E \
      's/(^|[[:space:]])(480p|720p|1080p|2160p|4k|8k|x264|x265|h264|h265|hevc|av1|bluray|blu[[:space:]-]?ray|web[[:space:]-]?dl|webrip|hdrip|bdrip|dvdrip|remux|hdr10\+?|hdr|aac|dts|truehd|atmos|proper|repack|limited|extended|uncut|dual[[:space:]-]?audio|multi[[:space:]-]?audio|10bit|8bit|yify|yts|rarbg)([[:space:]]|$)/\1\3/Ig')

    printf '%s' "$n" |
        sed -E 's/[[:space:]]+/ /g; s/^[[:space:]]+//; s/[[:space:]]+$//'
}

download_image() {
    local url="$1" base="$2"
    local tmp mime ext dest

    [[ "$url" == https://* || "$url" == http://* ]] || return 1

    tmp=$(mktemp "$workdir/.poster.XXXXXX") || return 1

    if ! curl -fLsS --connect-timeout 5 --max-time 30 \
        --max-filesize 15000000 "$url" -o "$tmp" 2>/dev/null; then
        rm -f "$tmp"
        return 1
    fi

    [[ -s "$tmp" ]] || { rm -f "$tmp"; return 1; }

    if command -v file >/dev/null 2>&1; then
        mime=$(file --mime-type -b "$tmp" 2>/dev/null || true)
    else
        mime=""
    fi

    case "$mime" in
        image/jpeg) ext=jpg ;;
        image/png)  ext=png ;;
        image/webp) ext=webp ;;
        image/gif)  ext=gif ;;
        image/bmp)  ext=bmp ;;
        *)
            rm -f "$tmp"
            return 1
            ;;
    esac

    dest="$workdir/$base.$ext"

    if [[ -e "$dest" ]]; then
        rm -f "$tmp"
        return 1
    fi

    if mv -- "$tmp" "$dest"; then
        log "Downloaded poster: $dest"
        return 0
    fi

    rm -f "$tmp"
    return 1
}

find_existing_image() {
    local base="$1" candidate
    local -a preferred=(
        "$base.jpg" "$base.jpeg" "$base.png" "$base.webp"
        "$base.bmp" "$base.gif"
    )

    for candidate in "${preferred[@]}"; do
        if [[ -f "$candidate" ]]; then
            printf '%s' "$candidate"
            return 0
        fi
    done

    while IFS= read -r -d '' candidate; do
        printf '%s' "${candidate#./}"
        return 0
    done < <(
        find . -maxdepth 1 -type f \
          \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
          -o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.gif' \) \
          ! -name '.poster.*' -print0
    )

    return 0
}

extract_year() {
    printf '%s' "$1" |
        grep -oE '(^|[^0-9])(19[89][0-9]|20[0-2][0-9])([^0-9]|$)' |
        grep -oE '(19[89][0-9]|20[0-2][0-9])' | head -n 1 || true
}

extract_season() {
    printf '%s' "$1" |
        grep -oEi '(^|[^[:alnum:]])(S[0-9]{1,2}|Season[[:space:]_-]?[0-9]{1,2})([^[:alnum:]]|$)' |
        head -n 1 || true
}

process_item() {
    local target="$1"
    local parent original cleaned workdir base
    local year season season_num search_title
    local img="" url="" video="" child
    local had_children=0

    [[ -e "$target" ]] || {
        log "Missing path: $target"
        return 0
    }

    if [[ -f "$target" ]]; then
        case "${target##*.}" in
            mkv|MKV|mp4|MP4|avi|AVI|webm|WEBM|m4v|M4V|mov|MOV|mpg|MPG|mpeg|MPEG|ts|TS)
                ;;
            *)
                log "Skipped non-video: $target"
                return 0
                ;;
        esac

        parent=$(dirname -- "$target")
        original=$(basename -- "$target")
        cleaned=$(clean_name "${original%.*}")
        [[ -n "$cleaned" ]] || cleaned="${original%.*}"
        workdir="$parent/$cleaned"

        if [[ -e "$workdir" && ! -d "$workdir" ]]; then
            log "Destination conflict: $workdir"
            return 0
        fi

        mkdir -p -- "$workdir" || return 0

        if [[ -e "$workdir/$original" ]]; then
            log "File already exists: $workdir/$original"
            return 0
        fi

        mv -- "$target" "$workdir/" || {
            log "Failed to move video: $target"
            return 0
        }

    elif [[ -d "$target" ]]; then
        parent=$(dirname -- "${target%/}")
        original=$(basename -- "${target%/}")
        cleaned=$(clean_name "$original")
        [[ -n "$cleaned" ]] || cleaned="$original"
        workdir="$target"

        if [[ "$cleaned" != "$original" && ! -e "$parent/$cleaned" ]]; then
            if mv -- "$target" "$parent/$cleaned"; then
                workdir="$parent/$cleaned"
            fi
        fi
    else
        return 0
    fi

    workdir=$(cd -- "$workdir" && pwd -P) || return 0
    base=$(basename -- "$workdir")

    while IFS= read -r -d '' child; do
        had_children=1
        process_item "$child"
    done < <(find "$workdir" -mindepth 1 -maxdepth 1 -type d -print0)

    if [[ "$had_children" -eq 1 ]]; then
        return 0
    fi

    log "Processing: $workdir"

    year=$(extract_year "$base")
    season=$(extract_season "$base")

    search_title="$base"
    search_title=$(printf '%s' "$search_title" |
        sed -E 's/(^|[^[:alnum:]])(S[0-9]{1,2}|Season[[:space:]_-]?[0-9]{1,2})([^[:alnum:]]|$)/ /Ig')
    search_title=$(printf '%s' "$search_title" |
        sed -E 's/(^|[^0-9])(19[89][0-9]|20[0-2][0-9])([^0-9]|$)/ /g; s/[[:space:]]+/ /g; s/^[[:space:]]+//; s/[[:space:]]+$//')
    [[ -n "$search_title" ]] || search_title="$base"

    cd -- "$workdir" || return 0
    img=$(find_existing_image "$base")

    # --------------------------------------------------
    # ONLINE SEARCH: ONLY MyAnimeList & IMDb
    # --------------------------------------------------
    if [[ -z "$img" ]]; then
        # 1. Try MyAnimeList first (for anime)
        url=$(jikan_poster "$search_title")
        [[ -n "$url" ]] && download_image "$url" "$base" || true

        [[ -z "$img" ]] && img=$(find_existing_image "$base")

        # 2. Try IMDb (for movies and series)
        if [[ -z "$img" ]]; then
            url=$(imdb_poster "$search_title")
            [[ -n "$url" ]] && download_image "$url" "$base" || true
            img=$(find_existing_image "$base")
        fi
    fi

    # --------------------------------------------------
    # FALLBACK: Extract video frame with FFmpeg
    # --------------------------------------------------
    if [[ -z "$img" ]] && command -v ffmpeg >/dev/null 2>&1; then
        video=""

        while IFS= read -r -d '' child; do
            video="$child"
            break
        done < <(
            find . -maxdepth 1 -type f \
              \( -iname '*.mkv' -o -iname '*.mp4' -o -iname '*.avi' \
              -o -iname '*.webm' -o -iname '*.m4v' -o -iname '*.mov' \
              -o -iname '*.mpg' -o -iname '*.mpeg' -o -iname '*.ts' \) \
              -print0
        )

        if [[ -n "$video" && ! -e "$base.jpg" ]]; then
            if ffmpeg -nostdin -loglevel error -ss 00:00:20 \
                -i "$video" -frames:v 1 -q:v 2 "$base.jpg" -y \
                </dev/null >/dev/null 2>&1; then
                [[ -s "$base.jpg" ]] && img="$base.jpg"
            fi
        fi
    fi

    if [[ -n "$img" && -f "$img" ]]; then
        local full_image
        full_image=$(realpath -- "$img") || return 0

        printf '[Desktop Entry]\nIcon=%s\n' "$full_image" > .directory

        if gio set -t string . metadata::custom-icon "file://$full_image" 2>/dev/null; then
            log "Icon set: $workdir"
        else
            log "Image found, but custom-icon metadata failed: $workdir"
        fi
    else
        log "No image available: $workdir"
    fi
}

if [[ "$#" -eq 0 ]]; then
    log "No paths supplied."
    exit 0
fi

for item in "$@"; do
    process_item "$item"
done
SCRIPT

chmod +x "$BIN/folder_processor.sh"

cat > "$ACTIONS/folder-icon.nemo_action" <<'ACTION'
[Nemo Action]
Active=true
Name=Clean Name & Set Movie/Anime Poster...
Comment=Local image -> MyAnimeList -> IMDb -> Video frame
Exec=/bin/bash -c '"$HOME/.local/bin/folder_processor.sh" "$@"' nemo %F
Icon-Name=image-x-generic
Selection=s
Extensions=dir;mkv;mp4;avi;webm;m4v;mov;mpg;mpeg;ts;
Quote=none
ACTION

nemo -q >/dev/null 2>&1 || true

echo "----------------------------------------------------"
echo "Installation completed successfully!"
echo "----------------------------------------------------"
