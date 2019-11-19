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

blast(blast = "tblastn",
      blast_db = "/home/$USER/research_drive/geodescent/samples/MGYS00000974/blast/megahit_untrimmed2/megahit_untrimmed2",
      input = "/home/$USER/scpackage/inst/extdata/'M.6 M.17 IR1.txt'",
      out = "/home/$USER/research_drive/geodescent/samples/MGYS00000974/blast/test_tblastn_tabular",
      format = 6)

blast(blast = "tblastn",
      blast_db = "/home/$USER/research_drive/geodescent/samples/MGYS00000974/blast/IR1_nucl_db/IR1_nucl_db",
      input = "/home/$USER/scpackage/inst/extdata/'M.6 M.17 IR1.txt'",
      out = "/home/$USER/research_drive/geodescent/samples/MGYS00000974/blast/test_tblastn_tabular_IR1",
      format = 6)
