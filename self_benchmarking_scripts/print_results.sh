#!/bin/bash

# Directory containing the .out files
OUT_DIR="."

# Pattern to search for in the output files
SEARCH_PATTERN="Total calculation time:"

# Loop through all relevant .out files
for file in $OUT_DIR/*.out; do
  if [[ -f "$file" ]]; then
    # Extract the number of CPUs from the filename
    cpus=$(echo "$file" | grep -oE "test_cpu_([0-9]+)" | grep -oE "[0-9]+")

    # Extract the line containing the search pattern
    line=$(grep "$SEARCH_PATTERN" "$file")

    if [[ -n "$line" ]]; then
      # Extract the numerical value (time in seconds) from the line
      time_in_seconds=$(echo "$line" | grep -oE "[0-9]+\.[0-9]+")

      # Convert the time to minutes
      time_in_minutes=$(echo "scale=2; $time_in_seconds / 60" | bc)

      # Print the CPUs, filename, and time in minutes
      echo "File: $file, CPUs: $cpus, Time: $time_in_minutes minutes"
    else
      echo "File: $file, CPUs: $cpus, No calculation time found"
    fi
  fi
done

