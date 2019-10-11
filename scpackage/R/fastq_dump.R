#' fastq-dump sratoolkit in R
#'
#' @param split '--split-files' can be added here, for paired end reads. Default "".
#' @param path Path to input SRA object
#'
#' @return Dumped fastq files
#' @export
#'
#' @examples
#' fastq_dump("--split-files", "inst/extdata/SRR7778149.1")
fastq_dump = function(split="",path) {
  command = paste0("fastq-dump ", split, " ", path)
  system(command)
}

fastq_dump("--split-files", "inst/extdata/SRR7778149.1")
system("mv SRR7778149.1_1.fastq inst/extdata/")
system("mv SRR7778149.1_2.fastq inst/extdata/")

fastq_dump(path="inst/extdata/SRR7778149.1")
system("mv SRR7778149.1.fastq inst/extdata/")
