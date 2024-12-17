library(ggplot2)
library(dplyr)
wd <- "~/Documents/Source/beast2.7/beast-beagle-benchmark/"
setwd(wd)

# Load the data
best_cpu_gpu <- rbind(read.csv("test_single_partition/results/best_cpu_vs_gpu.csv"), read.csv("test_partitions/results/best_cpu_vs_gpu.csv"))
best_cpu_gpu$totalSitesPatternsRatio <- round((best_cpu_gpu$nTaxa*best_cpu_gpu$nPartitions*best_cpu_gpu$partitionSeqLength)/best_cpu_gpu$totalSitePatterns, 2)
best_cpu_gpu$partitionSitesPattternsRatio <- round((best_cpu_gpu$nPartitions*best_cpu_gpu$partitionSeqLength)/best_cpu_gpu$totalSitePatterns, 2)

library(olsrr)
model <- lm(speedup ~ nPartitions + nTaxa + partitionSeqLength + totalSitePatterns, data = speedup_data)
k <- ols_step_all_possible(model)

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





# Save the plots
ggsave("scatter_gpu_speedup_fixed.png", width = 10, height = 8)
ggsave("barplot_gpu_speedup_fixed.png", width = 10, height = 8)
