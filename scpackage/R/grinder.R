#' Runs the biogrinder program to create artificial fastq reads from input genomes.
#'
#' @param reference_file Fasta file of genomes, path
#' @param abundance_file File of bundances of each genome for the reads, per line of file "name 22" name and perc.
#' @param fastq_output Default is 1, (true)
#' @param qual_levels Two quality values will be given: good / bad, default: "35 10"
#' @param mutation_dist Default is for Illumina sequences
#' @param outname Prefix name of output files
#' @param outdir Directory (will be created) to store output files in
#' @param coverage Library coverage
#'
#' @return
#' @export
#'
#' @examples
#' grinder(reference_file = "/home/$USER/scpackage/inst/extdata/GCA_002277835.1_ASM227783v1_genomic.fna",
#' abundance_file = "/home/$USER/abundance.txt",
#' outname = "test_grinder",
#' outdir = "grinder")
grinder = function(reference_file, 
                   abundance_file, 
                   fastq_output = "1", 
                   qual_levels = "35 10",
                   mutation_dist = "poly4 3e-3 3.3e-8",
                   outname,
                   outdir,
                   coverage = "1"){
  command = paste0("grinder -reference_file ", reference_file, 
                   " -fastq_output ", fastq_output,
                   " -qual_levels ", qual_levels,
                   " -mutation_dist ", mutation_dist,
                   " -base_name ", outname,
                   " -output_dir ", outdir,
                   " -coverage_fold ", coverage)
  print(command)
  system(command)
}
