#' Run tblastn
#'
#' @param blast_db String, path to blast database
#' @param input String, path to input query file
#' @param evalue Integer, evalue
#' @param format Integer, output format option
#'
#' @return blast_out
#' @export
#'
#' @examples
tblastn <- function(blast_db, input, evalue){
  tblastn = "/inst/programs/ncbi-blast-2.9.0+/bin/tblastn"
  format = 6 #tabular output
  #run tblastn
  blast_out <- system2(command = tblastn,
          args = c("-db", blast_db,
                   "-query", input,
                   "-outfmt", format,
                   "-evalue", evalue),
          wait = TRUE,
          stdout = TRUE)
  blast_out <- read.table(textConnection(blast_out))
}
