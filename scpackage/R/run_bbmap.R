#' Function to run bbmap program from r
#'
#' @param read1 first read fastq file path
#' @param read2 second read fastq file path
#' @param ref contig fasta file
#' @param outdir directory to store output
#'
#' @return Creates output at specififed dir
#' @export
#'
#' @examples run_bbmap(read1 = "/home/$USER/test_trimming/ERR1424899_1P",
#' read2 = "/home/$USER/test_trimming/ERR1424899_2P",
#' ref = "/home/$USER/renamed_contigs.fa",
#' outdir = "/home/$USER/bbmap_test")
run_bbmap = function(mode="PE", read1, read2="", ref, outdir) {
  program = "/opt/bbmap/bbmap.sh"
  if (mode == "PE"){
    args = c(
      paste0("ref=",ref),
      paste0("in=",read1),
      paste0("in2=",read2),
      "covstats=covstats.txt", "out=mapped.sam", "nodisk",
      "bamscript=bs.sh;", "sh", "bs.sh"
    )
    log = sys::exec_internal(program, args)
    stats = as_text(log$stderr)
    #creating outdir
    command = paste0("mkdir ", outdir)
    system(command)
    command = paste0("mv mapped_sorted* ", outdir,
                     " && ",
                     "mv covstats.txt ", outdir,
                     " && ",
                     "rm mapped.sam && rm bs.sh")
    system(command)
  } else {
    args = c(
      paste0("ref=",ref),
      paste0("in=",read1),
      "covstats=covstats.txt",
      "out=mapped.sam",
      "nodisk",
      "bamscript=bs.sh;",
      "sh",
      "bs.sh"
    )
    log = sys::exec_internal(program, args)
    stats = as_text(log$stderr)
    #creating outdir
    command = paste0("mkdir ", outdir)
    system(command)
    command = paste0("mv mapped_sorted* ", outdir,
                     " && ",
                     "mv covstats.txt ", outdir,
                     " && ",
                     "rm mapped.sam && rm bs.sh")
    system(command)
  }
  return(stats)
}
