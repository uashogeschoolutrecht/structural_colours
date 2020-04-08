#' This function is a wrapper for the blast+ suite tools.
#'
#' @param blast_db String, path to blast database (you can create a database useing the makeblastdb function)
#' @param blast String, type of blast search to perform, e.g. "tblastn" or "blastp"
#' @param input String, path to input query file (sequence to blast against the database)
#' @param e Integer, evalue cutoff to apply, default = 0.01
#' @param format Integer, format type to use for results, default = 6 (tabular). Options:
#' alignment view options:
#'   0 = pairwise,
#'   1 = query-anchored showing identities,
#'   2 = query-anchored no identities,
#'   3 = flat query-anchored, show identities,
#'   4 = flat query-anchored, no identities,
#'   5 = XML Blast output,
#'   6 = tabular,
#'   7 = tabular with comment lines,
#'   8 = Text ASN.1,
#'   9 = Binary ASN.1,
#'   10 = Comma-separated values,
#'   11 = BLAST archive format (ASN.1)
#'
#' @return blast_out File with blast results
#' @export
#'
#' @examples
#'\dontrun{
#' blast(blast = "tblastn",
#' blast_db = "/home/rstudio/data/tara_db/tara_db",
#' input = "/home/rstudio/scpackage/inst/extdata/sc_markers.faa",
#' out = "/home/rstudio/data/test_tara_10n2",
#' format = 6)
#' }
blast = function(blast,
                 blast_db,
                 input,
                 out,
                 e = 0.01,
                 format = 6) {
  command = paste0(blast,
                   " -db ",
                   blast_db,
                   " -query ",
                   input,
                   " -out ",
                   out,
                   " -evalue ",
                   e,
                   " -outfmt ",
                   format)
  blast_out = system(command)
  return(blast_out)
}

