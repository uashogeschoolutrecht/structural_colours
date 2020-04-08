#' Script to activate and run prokka on metagenome
#'
#' @param prokka_script Path to prokka.sh, "inst/prokka.sh"
#' @param contigpath Path to contigs file
#' @param outdir Output directory
#' @param prefix Name for output files
#'
#' @return
#' @export
#'
#' @examples
run_prokka = function(prokka_script, contigpath, outdir, prefix) {
  program = "bash"
  args = c(prokka_script, "-c", contigpath, "-o", outdir, "-p", prefix)
  log = sys::exec_internal(program, args)
  log = sys::as_text(log$stderr)
  return(log)
}
