#!/bin/zsh

# Directory containing the photo and video files
input_directory="$1"

# Check if directory is provided and exists
if [[ -z "$input_directory" || ! -d "$input_directory" ]]; then
    echo "Please provide a valid directory."
    exit 1
fi

cd "$input_directory"

# Define session threshold in seconds (e.g., 3600 seconds for 1 hour)
session_threshold=3600

# Initialize variables
prev_timestamp=0
session_number=0
session_count=0
first_timestamp=0

# Loop through sorted files
for file in $(ls | grep -E '^[0-9]{8}_[0-9]{6}\.(jpg|mp4)$' | sort); do
    # Extract timestamp from filename
    year=$(echo $file | cut -c1-4)
    month=$(echo $file | cut -c5-6)
    day=$(echo $file | cut -c7-8)
    hour=$(echo $file | cut -c10-11)
    minute=$(echo $file | cut -c12-13)
    second=$(echo $file | cut -c14-15)

    datetime_string="${year}${month}${day}_${hour}${minute}${second}"

    if [[ "$OSTYPE" == "darwin"* || "$OSTYPE" == "freebsd"* ]]; then
        # macOS or BSD systems
        timestamp=$(date -j -f "%Y%m%d_%H%M%S" "$datetime_string" "+%s" 2>/dev/null)
    else
        # GNU/Linux systems
        timestamp=$(date -d "$datetime_string" +%s 2>/dev/null)
    fi

    # Skip file if timestamp conversion failed
    if [ -z "$timestamp" ]; then
        echo "Skipping file with invalid date: $file"
        continue
    fi

    session_count=$((session_count + 1))

    # Calculate the difference in seconds from the previous file
    difference=$((timestamp - prev_timestamp))

    if [ $difference -gt $session_threshold ] || [ $prev_timestamp -eq 0 ]; then
        # Start a new session
        session_number=$((session_number + 1))
        if [[ "$OSTYPE" == "darwin"* || "$OSTYPE" == "freebsd"* ]]; then
            # macOS or BSD systems
            session_folder=$(date -j -f "%s" "$first_timestamp" "+%Y%m%d_%H%M%S" 2>/dev/null)
        else
            # GNU/Linux systems
            session_folder=$(date -d "@$first_timestamp" +"%Y%m%d_%H%M%S" 2>/dev/null)
        fi
        echo $session_number $session_folder $session_count
        first_timestamp=$timestamp
        session_count=0
    fi

    # Move file to session folder
    #mv "$file" "$session_folder/"

    # Update previous timestamp
    prev_timestamp=$timestamp

    # Display summary for the current session
    echo "Session $session_number: $(ls $session_folder | wc -l) files, Total size: $(du -sh $session_folder | cut -f1)"
done

echo "Files have been sorted and moved into session folders."
