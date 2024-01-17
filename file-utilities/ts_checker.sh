#!/bin/zsh
# USAGE: 
# ks1v@sidi Stage % ./ts_checker.sh ./HEAP ./ARCHIVE/media

# Input directory containing the files
input_directory="$1"
# Target directory to move non-compliant files
target_directory="$2"

# Check if directories are provided and exist
if [[ -z "$input_directory" || ! -d "$input_directory" ]]; then
    echo "Please provide a valid input directory."
    exit 1
fi

if [[ -z "$target_directory" ]]; then
    echo "Please provide a valid target directory."
    exit 1
fi

# Create target directory if it does not exist
mkdir -p "$target_directory"

# Regular expression for validating the datetime format at the start
regex='^([0-9]{4})(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])_([01][0-9]|2[0-3])([0-5][0-9])([0-5][0-9])'

# Loop through each filename found in the input directory
while IFS= read -r filename; do
    # Extract only the base filename without the path
    base_filename=$(basename "$filename")

    # Remove the file extension from the base filename
    filename_wo_ext="${base_filename%.*}"

    # Check if the filename without extension starts with a valid datetime format
    if ! [[ $filename_wo_ext =~ $regex ]]; then
        # Move the file to the target directory if it doesn't start with a valid datetime
        mv "$input_directory/$filename" "$target_directory/"
        echo "Moved: $filename"
    fi
done < <(find "$input_directory" -type f -maxdepth 1 -exec basename {} \;)

echo "Script completed."
