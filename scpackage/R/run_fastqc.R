#' Function to run fastqc program on the supplied file
#'
#' @param filepath Path to fastq file
#'
#' @return
#' @export
#'
#' @examples
#' run_fastqc("~/example.fastq")
run_fastqc = function(filepath, outdir) {
  command = paste0("/FastQC/fastqc ", filepath, " --outdir ", outdir)
  system(command)
}
