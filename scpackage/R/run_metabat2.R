#' This function runs the metabat2 program script
#'
#' @param metabat_script Path to mwetabat2 shell script
#' @param s_bam Sorted bam file path
#' @param fasta Contigs path
#'
#' @return Files created by metabat2
#' @export
#'
#' @examples
run_metabat2 = function(metabat_script, s_bam, fasta, outdir) {
  command = paste0("nohup bash ", metabat_script, " -b ", s_bam, " -f ", fasta, " -o ", outdir)
  system(command)
}
