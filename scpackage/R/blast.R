#' Run blast+
#'
#' @param blast_db String, path to blast database
#' @param input String, path to input query file
#' @param evalue Integer, evalue
#'
#' @return blast_out
#' @export
#'
#' @examples
blast = function(blast, blast_db, input, out, e = 0.01, format){
  command = paste0(blast, " -db ", blast_db, " -query ", input, " -out ", out, " -evalue ", e, " -outfmt ", format)
  blast_out = system(command)
  return(blast_out)
}
