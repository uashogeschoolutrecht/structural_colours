run_fastqc = function(filepath) {
  command = paste0("/FastQC/fastqc ", filepath)
  system(command)
}
