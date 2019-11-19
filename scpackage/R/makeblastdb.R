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

#creating blast database from IR1 genome nucleotides
makeblastdb(input = "/home/$USER/research_drive/geodescent/IR1/GCA_002277835.1_ASM227783v1_genomic.fna", out = "IR1_nucl_db", dbtype = "nucl")

makeblastdb(input = "/home/$USER/research_drive/geodescent/samples/MGYS00000974/blast/contigs/all_samples3.fa", out = "megahit_untrimmed2", dbtype = "nucl")
