model <- "coalescent"
maxNPartitions <- 9 # multiplier of 3, will test partitions from 1 to tis number, increasing by 3
maxCPUs <- 6 # will test threads from 1 to this number
maxGPUs <- 4 # will test GPUs from 1 to this number
instances <- c(T, F, NA) # if true: equal to threads, if false then threads-1, if NA then no instances
nTaxa <- c(20, 150, 500, 1000)
sequenceLength <- c(500, 1000, 3000, 6000)
substRate <- c(0.05, 0.005, 0.000005)
likelihood <- c("normal", "multipartition")
beagleCommand <- c("-java", "-beagle_CPU", "-beagle_SSE", "-beagle_GPU")
gpuOrder <- c(T, F) # previous testing suggested with GPUs it's better to specify order
seed <- 42