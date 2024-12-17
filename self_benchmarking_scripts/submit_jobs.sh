#!/bin/bash

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--minCPU)
            MIN="$2"
            shift; shift
            ;;
        -e|--maxCPU)
            MAX="$2"
            shift; shift
            ;;
        -i|--increment)
                    INC="$2"
                    shift; shift
                    ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Job script template
JOB_SCRIPT="job_template.slurm"

# Check if the job script exists
if [[ ! -f "$JOB_SCRIPT" ]]; then
  echo "Error: Job script $JOB_SCRIPT not found!"
  exit 1
fi

# Starting number of CPUs
i=1

# Submit the job 5 times with increasing CPU counts
for CPUS in $(seq "$MIN" "$INC" "$MAX"); do
  echo "Submitting job $i with $CPUS CPUs..."

  # Create a temporary job script with updated CPUs
  TEMP_JOB_SCRIPT="temp_job_$i.slurm"
  sed "s/%%CPUS%%/$CPUS/g" "$JOB_SCRIPT" > "$TEMP_JOB_SCRIPT"

  # Submit the job
  sbatch "$TEMP_JOB_SCRIPT"

  # Remove the temporary job script (optional)
  rm "$TEMP_JOB_SCRIPT"

  # Increment CPU count by 2
  i=$((i + 1))
done

echo "All jobs submitted."

