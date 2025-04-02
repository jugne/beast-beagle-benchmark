# Repo for benchmarking BEAST2 with Beagle on ETH Zurich Euler cluster.

Information about the study and it's results are summarised in [beast-beagle-benchmark.pdf](https://github.com/jugne/beast-beagle-benchmark/blob/main/beast-beagle-benchmark.pdf).

To benchmark your own analyses see [self_benchmarking_scripts](https://github.com/jugne/beast-beagle-benchmark/tree/main/self_benchmarking_scripts)

To reproduce benchmarking:
1. Clone repo to the cluster.
2. If needed, adjust the configuration for tests in `.env`
3. Run `run_xmls.sh`
4. Once all analyses are done, run `process.R`, the `results` folder now contains .csv files with summarised results for different configurations 
5. Finally, run `plots.R`, figures are saved in `plots` folder


