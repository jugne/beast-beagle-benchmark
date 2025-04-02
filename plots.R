library(ggplot2)
library(dplyr)
wd <- "~/Documents/Source/beast2.7/beast-beagle-benchmark/"
setwd(wd)

# Load the data
best_cpu_gpu <- rbind(read.csv("test_single_partition/results/best_cpu_vs_gpu.csv"), read.csv("test_partitions/results/best_cpu_vs_gpu.csv"))
best_cpu_gpu$totalSitesPatternsRatio <- round((best_cpu_gpu$nTaxa*best_cpu_gpu$nPartitions*best_cpu_gpu$partitionSeqLength)/best_cpu_gpu$totalSitePatterns, 2)
best_cpu_gpu$partitionSitesPattternsRatio <- round((best_cpu_gpu$nPartitions*best_cpu_gpu$partitionSeqLength)/best_cpu_gpu$totalSitePatterns, 2)

# Ensure unique configuration identifiers
best_cpu_gpu <- best_cpu_gpu %>%
  mutate(
    configuration = paste(nPartitions, nTaxa, partitionSeqLength, totalSitePatterns, totalSitesPatternsRatio, partitionSitesPattternsRatio, sep = "-")
  )

# Calculate speedup for configurations where both CPU and GPU times exist
speedup_data <- best_cpu_gpu %>%
  group_by(configuration, nPartitions, nTaxa, partitionSeqLength, totalSitePatterns) %>%
  summarize(
    cpu_time = min(time.minutes.[nGPU == 0], na.rm = TRUE),
    gpu_time = min(time.minutes.[nGPU > 0], na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(speedup = ifelse(!is.na(cpu_time) & !is.na(gpu_time), cpu_time / gpu_time, NA)) %>%
  filter(!is.na(speedup))

# Calculate speedup for configurations where both CPU and GPU times exist
speedup_data_partitions <- speedup_data %>%
  group_by(nPartitions) 

speedup_data_single <- speedup_data[speedup_data$nPartitions==1,]
speedup_data_20Taxa <- speedup_data[speedup_data$nTaxa==20,]
speedup_data_250Taxa <- speedup_data[speedup_data$nTaxa==250,]
speedup_data_1000Taxa <- speedup_data[speedup_data$nTaxa==1000,]

p <- ggplot(speedup_data_20Taxa, aes(y=speedup, x=factor(nPartitions), group=totalSitePatterns, fill = totalSitePatterns)) + 
  geom_bar(position="dodge", stat="identity") + ylim(0, 10) +
  geom_hline(aes(yintercept = 1), colour = "red") + coord_flip() +
  labs(
    title = "20 taxa",
    x = "Number of partitions",
    y = "Speedup (best CPU Time / best GPU Time)",
    fill = "Total site patterns"
  ) +
  theme_minimal()
ggsave("plots/speedup_cpuVSgpu_20Taxa.pdf", p)

p <- ggplot(speedup_data_1000Taxa, aes(y=speedup, x=factor(nPartitions), group=totalSitePatterns, fill = totalSitePatterns)) + 
  geom_bar(position="dodge", stat="identity") + ylim(0, 10) +
  geom_hline(aes(yintercept = 1), colour = "red") + coord_flip() +
  labs(
    title = "1000 taxa",
    x = "Number of partitions",
    y = "Speedup (best CPU Time / best GPU Time)",
    fill = "Total site patterns"
  ) +
  theme_minimal()
ggsave("plots/speedup_cpuVSgpu_1000Taxa.pdf", p)

p <- ggplot(speedup_data_250Taxa, aes(y=speedup, x=factor(nPartitions), group=totalSitePatterns, fill = totalSitePatterns)) + 
  geom_bar(position="dodge", stat="identity") + ylim(0, 10) +
  geom_hline(aes(yintercept = 1), colour = "red") + coord_flip() +
  labs(
    title = "250 taxa",
    x = "Number of partitions",
    y = "Speedup (best CPU Time / best GPU Time)",
    fill = "Total site patterns"
  ) +
  theme_minimal()
ggsave("plots/speedup_cpuVSgpu_250Taxa.pdf", p)


# Load the data
worst_best_cpu <- rbind(read.csv("test_single_partition/results/best_vs_worst_cpu.csv"), read.csv("test_partitions/results/best_vs_worst_cpu.csv"))
worst_best_cpu$totalSitesPatternsRatio <- round((worst_best_cpu$nTaxa*worst_best_cpu$nPartitions*best_cpu_gpu$partitionSeqLength)/worst_best_cpu$totalSitePatterns, 2)
worst_best_cpu$partitionSitesPattternsRatio <- round((worst_best_cpu$nPartitions*worst_best_cpu$partitionSeqLength)/worst_best_cpu$totalSitePatterns, 2)

# Ensure unique configuration identifiers
worst_best_cpu <- worst_best_cpu %>%
  mutate(
    configuration = paste(nPartitions, nTaxa, partitionSeqLength, totalSitePatterns, totalSitesPatternsRatio, partitionSitesPattternsRatio, sep = "-")
  )

# Calculate speedup for configurations where both CPU and GPU times exist
speedup_data <- worst_best_cpu %>%
  group_by(configuration, nPartitions, nTaxa, partitionSeqLength, totalSitePatterns) %>%
  summarize(
    worst_time = time.minutes.[seq(1, nrow(worst_best_cpu), by = 2)],
    best_time = time.minutes.[seq(2, nrow(worst_best_cpu), by = 2)],
    .groups = "drop"
  ) %>%
  mutate(speedup = ifelse(!is.na(worst_time) & !is.na(best_time), worst_time / best_time, NA)) %>%
  filter(!is.na(speedup))

# Calculate speedup for configurations where both CPU and GPU times exist
speedup_data_partitions <- speedup_data %>%
  group_by(nPartitions) 

speedup_data_single <- speedup_data[speedup_data$nPartitions==1,]
speedup_data_20Taxa <- speedup_data[speedup_data$nTaxa==20,]
speedup_data_250Taxa <- speedup_data[speedup_data$nTaxa==250,]
speedup_data_1000Taxa <- speedup_data[speedup_data$nTaxa==1000,]

p <- ggplot(speedup_data_20Taxa, aes(y=speedup, x=factor(nPartitions), group=totalSitePatterns, fill = totalSitePatterns)) + 
  geom_bar(position="dodge", stat="identity") + ylim(0, 20) +
  geom_hline(aes(yintercept = 1), colour = "red") + coord_flip() +
  labs(
    title = "20 taxa",
    x = "Number of partitions",
    y = "Speedup (worst CPU Time / best CPU Time)",
    fill = "Total site patterns"
  ) +
  theme_minimal()
ggsave("plots/speedup_worstVSbest_cpu_20Taxa.pdf", p)

p <- ggplot(speedup_data_1000Taxa, aes(y=speedup, x=factor(nPartitions), group=totalSitePatterns, fill = totalSitePatterns)) + 
  geom_bar(position="dodge", stat="identity") + ylim(0, 20) +
  geom_hline(aes(yintercept = 1), colour = "red") + coord_flip() +
  labs(
    title = "1000 taxa",
    x = "Number of partitions",
    y = "Speedup (worst CPU Time / best CPU Time)",
    fill = "Total site patterns"
  ) +
  theme_minimal()
ggsave("plots/speedup_worstVSbest_cpu_1000Taxa.pdf", p)

p <- ggplot(speedup_data_250Taxa, aes(y=speedup, x=factor(nPartitions), group=totalSitePatterns, fill = totalSitePatterns)) + 
  geom_bar(position="dodge", stat="identity") + ylim(0, 20) +
  geom_hline(aes(yintercept = 1), colour = "red") + coord_flip() +
  labs(
    title = "250 taxa",
    x = "Number of partitions",
    y = "Speedup (worst CPU Time / best CPU Time)",
    fill = "Total site patterns"
  ) +
  theme_minimal()
ggsave("plots/speedup_worstVSbest_cpu_250Taxa.pdf", p)


for (d in c("test_single_partition", "test_partitions")){
  folder <- paste0(d,"/results/")
  files <- list.files(path = folder, pattern = "^\\d+_\\d+_\\d+_\\d+\\.csv$", full.names = F)
  
  for (f in files){
    config <- read.csv(paste0(folder,"/",f))
    taxa <- strsplit(f, "_")[[1]][1]
    partitions <- strsplit(f, "_")[[1]][3]
    patterns <- strsplit(strsplit(f, "_")[[1]][4], "\\.")[[1]][1]
    config$speedup <- max(config$time.minutes., na.rm = T)/config$time.minutes.
    config$nCores <- pmax(config$nCPU, config$nGPU)
    
    # Ensure beagle is a factor with the desired order
    config$beagle <- factor(config$beagle, levels = c("java", "beagle_CPU", "beagle_SSE", "beagle_GPU"))
    
    p <- ggplot(config, aes(x = nCores, y = speedup, color = beagle, linetype = instances)) +
      geom_point() +
      geom_line(linewidth = 0.5) +
      scale_color_manual(values = c("java" = "black", 
                                    "beagle_CPU" = "red", 
                                    "beagle_SSE" = "blue", 
                                    "beagle_GPU" = "purple")) +
      labs(
        title = paste(taxa,"taxa,",patterns,"patterns"),
        # x = "",
        # y = "",
        x = "Number of Cores (CPU) or GPUs used",
        y = "Speedup",
        color = "Beagle Variant",
        linetype = "Instances"
      ) + 
      theme_minimal() +
      theme(
        text = element_text(size = 12),
        legend.position = "bottom",
        plot.title = element_text(hjust = 0.5, size = 14, face = "bold")
      )
    ggsave(paste0("plots/speedup_",strsplit(f, "\\.")[[1]][1],".pdf"), p, width=10.3, height=2.2)
  }
}

data.frame(nCPUs=c(1, 1, 1), time=c(53771.548, 2177.725, 1062.271), nGPUs=c(0, 0, 1), beagle_option=c("java", "beagle_SSE", "beagle_GPU" ))
