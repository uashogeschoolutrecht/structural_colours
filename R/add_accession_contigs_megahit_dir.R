#' Function to concatenate megahit final contigs into one fasta file with sample accession added to the headers.
#' This function can be used to create one file for input in makeblastdb to create a blast database of all the final contigs.
#' @param megahit_dir String, path to directorty in which the fastq files are present, here the blast and contigs folder will be made.
#' @param outfile String, path to output file to create.
#'
#' @return This functions creates the output file specified, containing the sequencing in fasta format.
#' @export
#'
#' @examples
#'\dontrun{
#' add_accession_contigs_megahit(megahit_dir = "/home/$USER/research_drive/geodescent/samples/MGYS00000974/megahit",
#'                               outfile = "/home/$USER/research_drive/geodescent/samples/MGYS00000974/blast/contigs/all_samples2.fa")
#'                               }
add_accession_contigs_megahit_dir = function(megahit_dir,
                                             outfile) {
  files = list.files(megahit_dir)
  paths_to_contigs = paste0(megahit_dir, "/", files, "/final.contigs.fa")

  for (i in 1:length(paths_to_contigs)) {
    path_to_contigs = paths_to_contigs[i]
    print(path_to_contigs)

    split = strsplit(path_to_contigs, "megahit_")[[1]]
    split = dplyr::last(split)
    accession = strsplit(split, ".f")[[1]][1]

    command = paste0("sed 's/>/",
                     ">",
                     accession,
                     "_",
                     "/' ",
                     path_to_contigs,
                     " >> ",
                     outfile)
    system(command)
  }
}
