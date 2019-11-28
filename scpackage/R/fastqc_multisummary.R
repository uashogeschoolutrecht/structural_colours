fastqc_multisummary = function(results_dir) {
  old_wd = getwd()
  setwd(results_dir)
  system("touch fastqc_multisummary.txt")
  samples = list.files(path = results_dir)
  samples_paths = paste0(results_dir, "/", samples)
  for (path in samples_paths) {
    if (grepl("fastqc.zip", path) == TRUE){
      # set wd to results dir and unzip the reports there
      command = paste0("unzip ", path)
      system(command)

      #get name outdir and path to summary
      out_dir_name = substr(path, start = 1, stop = nchar(path)-4)
      summary_path = paste0(out_dir_name, "/summary.txt")

      #append to multisummary
      command = paste0("cat ", summary_path, " >> fastqc_multisummary.txt")
      system(command)
    }
  }
  #create visualization
  multisum = read.csv("fastqc_multisummary.txt", sep = '\t', header = FALSE)
  multisum$V1 = factor(multisum$V1, levels = c("FAIL", "WARN", "PASS"))
  qc_plot = ggplot(multisum, aes(x = V1, y = V2, color = V1)) +
    ggtitle("FastQC summaries per sample") +
    xlab("Result") + ylab("FastQC test") +
    scale_color_manual(values=c("red", "orange", "green")) +
    geom_point(show.legend = FALSE) +
    facet_wrap(. ~ V3, ncol=5)

  print(old_wd)
  setwd(old_wd)
  return(qc_plot)
}
