#' Function to add a prefix to the headers of the fasta file outputs from MEGAHIT and concatenate into one file for makeblastdb.
#'
#' @param samples_dir Directorty in which the fastq files are present, here the blast and contigs folder will be made.
#' @param sra_sampletype Type of experiment, e.g. ERR, ERS.
#' @param sample_nums_from Run / sample number, e.g. ERR101
#' @param sample_nums_to Run / sample number, e.g. ERR909
#' @param outfile File to concatenate fasta seqs into
#'
#' @return This functions creates two nested dirs and a file with concatenated fasta seqs with sample accession as prefix in the header
#' @export
#'
#' @examples
#' add_accession_contigs_megahit(samples_dir = "/home/$USER/research_drive/geodescent/samples/MGYS00000974/",
#'                               sra_sampletype = "ERR",
#'                               sample_nums_from = 833272,
#'                               sample_nums_to = 833616,
#'                               outfile = "/home/$USER/research_drive/geodescent/samples/MGYS00000974/blast/contigs/all_samples2.fa")
add_accession_contigs_megahit_dir = function(samples_dir,
                                         sra_sampletype,
                                         sample_nums_from,
                                         sample_nums_to,
                                         outfile) {
  if (!file.exists(paste0(samples_dir, "blast"))) {
    command = paste0("mkdir ", samples_dir, "blast")
    system(command)
  } else {
    print("Output dir blast exists")
  }
  if (!file.exists(paste0(samples_dir, "blast/contigs"))) {
    command = paste0("mkdir ", samples_dir, "blast/contigs")
    system(command)
  } else {
    print("Output dir contigs exists")
  }

  samples = ""
  for (num in seq(from = sample_nums_from, to = sample_nums_to, by = 1)) {
    accession = paste0(sra_sampletype, as.character(num))
    samples = append(samples, accession)
    path_to_contigs = paste0(
      samples_dir,
      "megahit/",
      accession,
      "/final.contigs.fa"
    )
    command = paste0("sed 's/>/",
                     ">",
                     accession, "_",
                     "/' ",
                     path_to_contigs,
                     " >> ",
                     outfile)
    system(command)
  }
}
#sed 's/>.*/phosphate_&/' foo.in >bar.out
