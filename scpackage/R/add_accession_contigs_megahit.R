#' This function takes adds a prefix to the headers of a final contigs fasta file
#'
#' @param megahit_outdir Path to directory of megahit results where the final contigs are in, e.g. "/home/$USER/megahit"
#' @param prefix Prefix to add to seqid of fasta file, will be added as prefix_, e.g. "sample1"
#' @param outfile Filename of new renamed fasta file, will be created by script.
#'
#' @return A new file with the renamed fasta sequences will be created at the supplied path
#' @export
#'
#' @examples
add_accession_contigs_megahit2 = function(megahit_outdir,
                                          prefix,
                                          outfile) {
  command = paste0("touch ", outfile)
  system(command)
  path_to_contigs = paste0(
    megahit_outdir,
    "/final.contigs.fa"
  )
  command = paste0("sed 's/>/",
                   ">",
                   prefix,
                   "_",
                   "/' ",
                   path_to_contigs,
                   " >> ",
                   outfile
  )
  system(command)
}
