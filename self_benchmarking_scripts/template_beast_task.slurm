#!/bin/bash
#SBATCH --job-name=my_job
#SBATCH --ntasks=1
#SBATCH --time=01:00:00
#SBATCH --mem-per-cpu=1G
#SBATCH --cpus-per-task=%%CPUS%%
#SBATCH --output=job_%%CPUS%%.out


# DO NOT change the last two lines above. You may always add more options.
# Your job commands should be below and contain 
# "-threads -1" OR "-threads %%CPUS%%" option to BEAST
# This script is only intended for jobs NOT using GPUs

