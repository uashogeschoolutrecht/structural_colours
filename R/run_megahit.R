#' This script is a R wrapper for the bash script megahit.sh to run the megahit assembly tool
#'
#' @param PE TRUE/FALSE. Wether paired end or single end library is supplied. Default = T
#' @param nohup can be set to "nohup" to run assembly in background. Default = ""
#' @param script_path Path to megahit.sh, e.g. "/home/$USER/scpackage/inst/megahit.sh"
#' @param r1 Path to read file one, paired end or single end
#' @param r2 Path to paired end read
#' @param outdir Existing directory to create output directory in
#' @param outname Output directory name, will be created by program
#'
#' @return A directory with output files will be created at supplied path
#' @export
#'
#' @examples run_megahit(script_path = "/home/$USER/scpackage/inst/megahit.sh",
#' r1 = "/home/$USER/data/geodescent/samples/MGYS00000991/ERR1424899_1.fastq.gz",
#' r2 = "/home/$USER/data/geodescent/samples/MGYS00000991/ERR1424899_2.fastq.gz",
#' outdir = "/home/$USER",
#' outname = "megahit_testing")
run_megahit = function(PE = T,
                       nohup = "",
                       script_path,
                       r1,
                       r2 = "",
                       outdir,
                       outname = "megahit") {
  if (PE == T) {
    command = paste0(nohup,
                     " ",
                     "bash ",
                     script_path,
                     " -p ",
                     r1,
                     ",",
                     r2,
                     " -o ",
                     outdir,
                     " -n ",
                     outname)
    system(command)
  } else {
    command = paste0(nohup,
                     " ",
                     "bash ",
                     script_path,
                     " -s ",
                     r1,
                     " -o ",
                     outdir,
                     " -n ",
                     outname)
    system(command)
  }
}
