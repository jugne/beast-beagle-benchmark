### Sripts to benchmark your analyses by increasing the number of CPU cores used

1. Add your submission command to `template_beast_task.slurm`. Make sure you are running not more than 10^6 iterations as this is enough for benchmarking.
2. On Euler, submit the jobs using command `./submit_jobs.sh --minCPU 1 --maxCPU 4 --increment 1`. This will execute your job 4 times, starting with 1 CPU core and increasing by 1 till 4 cores are reached. You may adjust these values.
3. Your jobs will produce .out files names `job_nCPUsUsed.out`.
4. When all jobs are finished, use print_results.sh script to see the runtime results.

