#' Run tblastn
#'
#' @param blast_db String, path to blast database (nucleotide)
#' @param input String, path to input query file (protein fasta)
#' @param evalue Integer, evalue
#'
#' @return blast_out
#' @export
#'
#' @examples
#' tblastn()
tblastn = function(blast_db, input, out, e = 0.01){
  format = 6 #tabular output
  #run tblastn
  command = paste0("tblastn", " -db ", blast_db, " -query ", input, " -out ", out, " -evalue ", e)
  tblastn_out = system(command, wait = TRUE)
  #tblastn_out = read.table(textConnection(tblastn_out))
  return(tblastn_out)
}

#inst/extdata/M.6\ M.17\ IR1.txt escaping spaces in original filename

tblastn("data/IR1_nucl_db/IR1_nucl_db", "inst/extdata/'M.6 M.17 IR1.txt'", "M17_IR1_tblastn", 0.01)
system("mv M17_IR1_tblastn data")

