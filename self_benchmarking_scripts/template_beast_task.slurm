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
srun java -Dglass.platform=Monocle -Dmonocle.platform=Headless -Dprism.order=sw --module-path /cluster/home/jugne/javafx-sdk-17.0.6-linux-monocle/lib --add-modules javafx.controls,javafx.fxml,javafx.graphics,javafx.web -Dbeagle.resource.auto=true -jar /cluster/home/jugne/beast2.jar -seed 42 -threads -1 benchmark_FR_80p_dp5_SOR_QC_names_with_Tohama_recom_masked_snp_BEAST.xml


