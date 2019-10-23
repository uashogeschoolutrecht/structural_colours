#' Calculate the range of fastq quality scores.
#'
#' @param qual_cat String of all the quality scores from the fastq file (ASCII characters)
#'
#' @return The decimal ASCII range of the quality scores
#' @export
#'
#' @examples
#' file = readLines(con = "/home/rstudio/scpackage/inst/ERR833272_2.fastq")
#' all_qual = scpackage::concatenate_qualities(file)
#' ASCII_range_concatenated_qualities(all_qual)
ASCII_range_concatenated_qualities = function(qual_cat) {
  library(gtools)
  nums <- gtools::asc(qual_cat, simplify = TRUE)
  range = append(min(nums), max(nums))
  return(range)
}