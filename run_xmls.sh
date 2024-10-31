source .env

module load stack/2024-06 openjdk/17.0.8.1_1 libbeagle/3.1.2 beast2/2.7.4
#packagemanager -add BEASTLabs
packagemanager -add remaster
packagemanager -add feast

n=1
output_file="data.csv"
# Write the header
echo "run,nPartitions,nTaxa,partitionSeqLength,nCPU,instances,beagle,nGPU" > "$output_file"
# for single partition
for taxa in "${nTaxaSingleP[@]}"; do
  for length in "${sequenceLengthSingleP[@]}"; do
    for ins in "${instances[@]}"; do
      inst=""
      if [ ${ins} = "true" ]; then
        inst="-instances ${c}"
      fi
      for c in "${cpus[@]}"; do
        for r in "${beagleCPUCommand[@]}"; do
          eval "sbatch -J ${n} --time=48:00:00 --output \"${n}_${taxa}_${length}_1_cpu_${c}_${r}_${ins}.out\" --open-mode=truncate --ntasks="${c}" --wrap=\"beast -seed ${seed} -${r} ${inst} -threads ${c} -D \"nTaxa=${taxa},sl=${length},range=1\" ${xmlSingleName}\""
          echo "n,1,${taxa},${length},${c},${ins},${r},0" >> "$output_file"
          let n+=1
        done
      done
      for g in "${gpus[@]}"; do
        eval "sbatch -J ${n} --time=48:00:00 --output \"${n}_${taxa}_${length}_1_gpu_${g}_${ins}.out\" --open-mode=truncate --gpus ${g} --wrap=\"beast -seed ${seed} -beagle_GPU -beagle_order $(seq -s "," 1 "$g") ${inst} -threads ${g} -D \"nTaxa=${taxa},sl=${length},range=1\" ${xmlSingleName}\""
        echo "n,1,${taxa},${length},1,${ins},${r},${g}" >> "$output_file"
        let n+=1
      done
    done
  done
done


for taxa in "${nTaxaMultiP[@]}"; do
  for length in "${sequenceLengthMultiP[@]}"; do
    for p in "${nPartitions[@]}"; do
      for ins in "${instances[@]}"; do
        inst=""
        if [ ${ins} = "true" ]; then
        inst="-instances ${c}"
        fi
        for c in "${cpus[@]}"; do
          for r in "${beagleCPUCommand[@]}"; do
            eval "sbatch -J ${n} --time=48:00:00 --output \"${n}_${taxa}_${length}_${p}_cpu_${c}_${r}_${ins}.out\" --open-mode=truncate --ntasks="${c}" --wrap=\"beast -seed ${seed} -${r} ${inst} -threads ${c} -D \"nTaxa=${taxa},sl=${length},range=$(seq -s "," 1 "$p")\" ${xmlMultiName}\""
            echo "n,${p},${taxa},${length},${c},${ins},${r},0" >> "$output_file"
            let n+=1
          done
        done
        for g in "${gpus[@]}"; do
            eval "sbatch -J ${n} --time=48:00:00 --output \"${n}_${taxa}_${length}_${p}_gpu_${g}_${ins}.out\" --open-mode=truncate --gpus ${g} --wrap=\"beast -seed ${seed} -beagle_GPU -beagle_order $(seq -s "," 1 "$g") ${inst} -threads ${g} -D \"nTaxa=${taxa},sl=${length},range=$(seq -s "," 1 "$p")\" ${xmlMultiName}\""
            echo "n,${p},${taxa},${length},1,${ins},${r},${g}" >> "$output_file"
            let n+=1
        done
      done
    done
  done
done