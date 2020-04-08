#' Run makeblastdb and create output folder in data
#'
#' @param input String, path to input fasta file
#' @param out String, name of output files
#' @param dbtype String, name of database type "nucl" / "prot"
#'
#' @return
#' @export
#'
#' @examples
#' makeblastdb(input = "/home/rstudio/data/test_db_tara",
#' outname = "tara_db",
#' outdir = "/home/rstudio/data/",
#' dbtype = "nucl")
makeblastdb <- function(input, outname, outdir, dbtype){
  #run makeblastdb
  command = paste0("makeblastdb", " -in ", input, " -out ", outname, " -parse_seqids ", " -dbtype ", dbtype)
  system(command, wait = TRUE)

  #moving files
  to = paste0(outdir, outname)
  create_to = paste0("mkdir", " ", to)
  system(create_to)
  command1 <- paste0("mv ", outname, ".*", " ", to)
  system(command1)
}


