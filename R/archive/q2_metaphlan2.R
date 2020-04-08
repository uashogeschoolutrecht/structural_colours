#' Runs metaphlan2.py on fastq files to assign taxonomy
#'
#' @param input fastq file path
#'
#' @return
#' @export
#'
#' @examples
q2_metaphlan2 <- function(input, bowtiedb, bowtieout, outfile) {
  program = "inst/metaphlan.sh"
  command = paste0(program,
                   " -i ", input,
                   " -d ", bowtiedb,
                   " -b ", bowtieout,
                   " -o ", outfile)
  print("Running following command in shell:")
  print(command)
  system(command)
}



