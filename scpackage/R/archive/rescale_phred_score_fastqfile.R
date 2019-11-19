#' Function to rescale the quality scores of fastq files and write to new fastq file.
#'
#' @param file_lines A fastq format file opened with readLines(), character vector of lines file.
#' @param scale_metric Integer, can be negative.
#' @param outfile Path of output location.
#'
#' @return A fastq format file will be written to the output location
#' @export
#'
#' @examples
#' file = readLines(con = "/home/rstudio/scpackage/inst/ERR833272_2.fastq")
#' rescale_phred_score_fastqfile(file_lines = file, scale_metric = -6, outfile = "/home/rstudio/scpackage/inst/ERR833272_2_scaled.fastq")
rescale_phred_score_fastqfile = function(file_lines, scale_metric, outfile) {
  counts = c()
  counter2 = 0
  for (line in file_lines) {
    for (i in seq(from = 4, to = 4, by = 4)) {
      counter2 = counter2 + 4
    }
    counts = append(counts, counter2)
  }
  counter = 1
  for (line in file_lines) {
    if (counter %in% counts) {
      qual_line = line
      quals = gtools::asc(qual_line, simplify = TRUE)
      quals_scaled = quals + scale_metric
      new_line = paste(gtools::chr(quals_scaled), sep="", collapse="")
      write(new_line, outfile, append=TRUE)
    } else {
      print("writing normal line")
      write(line, outfile, append=TRUE)
    }
    counter = counter + 1
  }
  return()
}