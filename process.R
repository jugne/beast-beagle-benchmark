rm(list=ls())

wd <- "~/Documents/Source/beast2.7/beast-beagle-benchmark/"
setwd(wd)
dir.create("results")

extract_time_to_minutes <- function(file_path) {
  # Read the file
  lines <- readLines(file_path)
  
  # Get the last line
  last_line <- tail(lines, 1)
  
  # Extract the time string using a regular expression
  time_string <- regmatches(last_line, regexpr("\\d+h\\d+m\\d+s", last_line))
  
  # Convert the time string to total minutes
  time_parts <- as.numeric(unlist(regmatches(time_string, gregexpr("\\d+", time_string))))
  total_minutes <- time_parts[1] * 60 + time_parts[2] + time_parts[3] / 60
  
  return(total_minutes)
}

# Load the data
data <- read.csv("data.csv")

# Add a row number column
data$row_number <- seq_len(nrow(data))

# Group by columns 2, 3, and 4, then create a list of row numbers for each group
library(dplyr)
grouped_data <- data %>%
  group_by(nPartitions, nTaxa, partitionSeqLength) %>%
  summarise(row_numbers = list(row_number), .groups = 'drop')


best_table <- data.frame() # Best running configurations for each data set up
best_table_cpu <- data.frame() # Best running configurations for each data set up, when using only CPUs
diff_table <- data.frame() # Worst and best running configurations for each data set up
diff_table_cpu <- data.frame() # Worst and best running configurations for each data set up, when using only CPUs
diff_table_cpu_gpu <- data.frame() # Best running configurations for CPU and GPU, for each data set up


for (g in 1:nrow(grouped_data)){
  # Full running results table for a particular data configuration
  # Data configuration is determined by # partitions, # taxa, sequence length and total site patterns
  config_table <- as.data.frame(matrix(NA, nrow = length(grouped_data$row_numbers[[g]]),
                                       ncol = ncol(data)+1))
  colnames(config_table) <- c(colnames(data[-9]), "time(minutes)", "totalSitePatterns")
  l = 1
  for (i in grouped_data$row_numbers[[g]]){
    file_path <- list.files(pattern = paste0("^",i,"_.*out"), full.names = TRUE)[[1]]
    # Read the file lines
    lines <- readLines(file_path)
    # Find lines with site patterns
    pattern_lines <- grep("\\b[0-9]+ patterns\\b", lines, value = TRUE)
    # Extract the numbers from those lines
    pattern_counts <- as.numeric(sub("([0-9]+) patterns", "\\1", pattern_lines))
    # Find the line that contains "Total calculation time"
    time_line <- grep("Total calculation time:", lines, value = TRUE)
    
    # Extract the numeric time value from the line
    if (length(time_line) > 0) {
      time_minutes <- as.numeric(sub(".*Total calculation time: ([0-9.]+) seconds.*",
                                     "\\1", time_line)) / 60
      config_table[l, ]<- c(data[i,-9], time_minutes, sum(pattern_counts))
    } else if (length(extract_time_to_minutes(file_path))>0) {
      time_minutes <- extract_time_to_minutes(file_path)
      config_table[l, ]<- c(data[i,-9], time_minutes, sum(pattern_counts))
    }else {
      config_table[l, ]<- c(data[i,-9], NA, sum(pattern_counts))
      # stop(paste("Time not found for run,",i))
    }
    
    l = l + 1
  }
  # Reorder columns so that site patterns are grouped with data configuration
  config_table <- config_table[,c(1:4,10,5:9)]
  # Save table for all results, given a particular configuration.
  # Table is named: nTaxa_seqLength_nPartitions_totalSitePatterns
  write.csv(config_table,paste0("results/",paste(grouped_data[g,2], 
                                      grouped_data[g,3],
                                      grouped_data[g,1],
                                      config_table[1,5],
                                      sep="_"), ".csv"))
  best_table <- rbind(best_table,
                      config_table[which.min(config_table$`time(minutes)`),])
  diff_table <- rbind(diff_table,
                      config_table[which.max(config_table$`time(minutes)`),])
  diff_table <- rbind(diff_table,
                      config_table[which.min(config_table$`time(minutes)`),])
  
  tmp <- config_table[config_table$nGPU==0,]
  best_table_cpu <- rbind(best_table_cpu,
                          tmp[which.min(tmp$`time(minutes)`),])
  diff_table_cpu <- rbind(diff_table_cpu,
                          tmp[which.max(tmp$`time(minutes)`),])
  diff_table_cpu <- rbind(diff_table_cpu,
                          tmp[which.min(tmp$`time(minutes)`),])
  
  tmp1 <- config_table[config_table$nGPU>0,]
  diff_table_cpu_gpu <- rbind(diff_table_cpu_gpu,
                              tmp[which.min(tmp$`time(minutes)`),])
  diff_table_cpu_gpu <- rbind(diff_table_cpu_gpu,
                              tmp1[which.min(tmp1$`time(minutes)`),])
}

write.csv(best_table,"results/best.csv")
write.csv(best_table_cpu,"results/best_cpu.csv")
write.csv(diff_table,"results/best_vs_worst.csv")
write.csv(diff_table_cpu,"results/best_vs_worst_cpu.csv")
write.csv(diff_table_cpu_gpu,"results/best_cpu_vs_gpu.csv")







