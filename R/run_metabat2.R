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
run_metabat2 = function(metabat_script, s_bam, fasta) {
  program = "bash"
  args = c(metabat_script, "-b", s_bam, "-f", fasta)
  log = sys::exec_internal(program, args)
  return(log)
}
