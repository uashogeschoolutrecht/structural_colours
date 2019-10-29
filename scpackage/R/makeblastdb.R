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
#' makeblastdb("inst/extdata/GCA_002277835.1_ASM227783v1_genomic.fna", "IR1_nucl_db", "nucl")
makeblastdb <- function(input, out, dbtype){
  #run makeblastdb
  command = paste0("makeblastdb", " -in ", input, " -out ", out, " -parse_seqids ", " -dbtype ", dbtype)
  system(command, wait = TRUE)

  #moving files
  to = paste0("data/", out)
  create_to = paste0("mkdir", " ", to)
  system(create_to)
  command1 <- paste0("mv ", out, ".nin", " ", to)
  command2 <- paste0("mv ", out, ".nhr", " ", to)
  command3 <- paste0("mv ", out, ".nsq", " ", to)
  command4 <- paste0("mv ", out, ".nsi", " ", to)
  command5 <- paste0("mv ", out, ".nsd", " ", to)
  command6 <- paste0("mv ", out, ".nog", " ", to)
  system(command1)
  system(command2)
  system(command3)
  system(command4)
  system(command5)
  system(command6)
}

#creating blast database from IR1 genome nucleotides
makeblastdb(input = "inst/extdata/GCA_002277835.1_ASM227783v1_genomic.fna", out = "IR1_nucl_db", dbtype = "nucl")

