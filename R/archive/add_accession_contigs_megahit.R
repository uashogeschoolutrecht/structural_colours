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
#' add_accession_contigs_megahit2(megahit_outdir = "/home/rstudio/data/megahit_tara/megahit",
#' outfile = "/home/rstudio/data/test_db_tara")
add_accession_contigs_megahit = function(megahit_outdir,
                                          outfile) {
  command = paste0("touch ", outfile)
  system(command)

  files = list.files(path = megahit_outdir)
  path_to_contigs = paste0(
    megahit_outdir, "/", files,
    "/final.contigs.fa"
  )

  for (path in path_to_contigs){
   prefix = strsplit(path, "megahit_")[[1]]
   prefix = strsplit(prefix[3], ".f")[[1]][1]

   print(path)
   print(prefix)

   command = paste0("sed 's/>/",
   ">",
   prefix,
   "_",
   "/' ",
   path,
   " >> ",
   outfile
   )
   system(command)
  }
}
