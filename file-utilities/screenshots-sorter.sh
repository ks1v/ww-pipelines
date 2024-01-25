#!/bin/zsh
# Name: Screenshots sorter
# Purpose: Sort incoming screenshots from movies one watch with VLC
# Author: @ks1v, ChatGPT-4 assisted
# Version: 1.0
# VLC snapshot prefix: "$N_$T"

screenshot_dir="/Users/ks1v/screenshots"
cd "$screenshot_dir"

# TODO 
#source vlc-default.sh 

draw_progress_bar() {
    local total=$1
    local current=$2
    local bar_width=50  # Width of the progress bar

    # Calculate the number of filled and empty slots in the bar
    local filled_slots=$((current * bar_width / total))
    local empty_slots=$((bar_width - filled_slots))

    # Create the filled and empty parts of the bar
    local filled_bar=$(printf '%0.s#' $(seq 1 $filled_slots))
    local empty_bar=$(printf '%0.s-' $(seq 1 $empty_slots))

    # Print the progress bar
    printf "\r[%s%s] %d/%d" "$filled_bar" "$empty_bar" $current $total
}

# Step 1: Get a sorted list of screenshot files
IFS=$'\n' files=($(ls | grep -E '.*_[0-9]+_[0-9]+_[0-9]+.*\.png' | sort))

# Step 2: Extract movie names, sanitize, create folders if needed, and print new movie names
last_moviename=""
declare -A movie_count
for file in $files; do
    moviename=$(echo "$file" | sed 's/_[0-9]*_[0-9]*_[0-9]*.*//' | cut -c 1-50)
    # Sanitize moviename by replacing special characters
    sanitized_moviename=$(echo "$moviename" | tr -c '[:alnum:]' ' ')

    # Check if current movie name is different from the last processed one
    if [[ "$sanitized_moviename" != "$last_moviename" ]]; then
        if [[ ! -d "$sanitized_moviename" ]]; then
            mkdir -p "$sanitized_moviename"
            echo "New movie: $sanitized_moviename"
        fi
        movie_count["$sanitized_moviename"]=0
        last_moviename="$sanitized_moviename"
    fi
done

# Step 3: Move files and count
total_files=${#files[@]}
current_file=0
echo "\nMoving:" 

for file in $files; do
    current_file=$((current_file + 1))
    draw_progress_bar $total_files $current_file

    moviename=$(echo "$file" | sed 's/_[0-9]*_[0-9]*_[0-9]*.*//' | cut -c 1-50)
    sanitized_moviename=$(echo "$moviename" | tr -c '[:alnum:]' ' ')
    
    mv "$file" "$sanitized_moviename/"
    movie_count[$sanitized_moviename]=$((movie_count[$sanitized_moviename] + 1))
done

# Step 4
echo "\n\nScreenshots moved per movie:"
for movie in "${(@k)movie_count}"; do
    if [[ "${movie_count[$movie]}" -gt 0 ]]; then
        printf "%-50s %d\n" "$movie" "${movie_count[$movie]}"
    fi
done

echo "\nEND"