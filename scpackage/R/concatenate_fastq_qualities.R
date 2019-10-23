#' Function to concatenate all quality string from a fastq file into one.
#'
#' @param file_lines A fastq format file opened with readLines(), character vector of lines file.
#'
#' @return A string of ASCII characters from the quality scores of the fastq file.
#' @export
#'
#' @examples
#' file = readLines(con = "/home/rstudio/scpackage/inst/ERR833272_2.fastq")
#' concatenate_fastq_qualities(file)
concatenate_fastq_qualities = function(file_lines) {
  quals_concat = ""
  for (i in seq(from = 4, to = length(file_lines), by = 4)) {
    qual = file_lines[i]
    quals_concat = append(quals_concat, qual)
  }
  quals_concat = quals_concat[-1]
  quals_concat = paste(quals_concat, sep="", collapse="") 
  return(quals_concat)
}