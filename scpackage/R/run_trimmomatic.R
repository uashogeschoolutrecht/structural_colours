#' This function uses trimmomatic to trim input fastq files and outputs them to the specified base dir. Please supply input as character type.
#'
#' @param mode Single end ("SE") or pairend end ("PE") fastq file(s) input, default = "SE"
#' @param f1 Absolute path to fastq read one, supply single end file / direction one PE here
#' @param f2 Absolute path to fastq read two, only use for second pairen end file not for single end file, default = "".
#' @param prefix Name of prefix for output files. Default = "trimmed"
#' @param phred Phred scale, e.g. 33 / 64. Default = "33"
#' @param minlen Minimum length of reads to keep, default = "90"
#' @param outdir Absolute path directory to store output files, default = "./trimmomatic". Directory will be made my script.
#' @param window Sliding window for quality trimming to use, default = "4:15"
#'
#' @return Creates trimming output files in specified directory
#' @export
#'
#' @examples
run_trimmomatic = function(mode = "SE",
                           f1,
                           f2 = "",
                           prefix = "trimmed",
                           phred = "33",
                           minlen = "90",
                           window = "4:15") {
  program = "java -jar /Trimmomatic-0.39/trimmomatic-0.39.jar"
  if (mode == "SE") {
    command = paste0(
      program,
      " ",
      mode,
      " ",
      f1,
      " ",
      " -baseout ",
      prefix,
      " MINLEN:",
      minlen,
      " SLIDINGWINDOW:",
      window,
      " -phred",
      phred
    )
    system(command)
  } else {
    command = paste0(
      program,
      " ",
      mode,
      " ",
      f1,
      " ",
      f2,
      " ",
      " -baseout ",
      prefix,
      " MINLEN:",
      minlen,
      " SLIDINGWINDOW:",
      window,
      " -phred",
      phred
    )
    system(command)
  }
}
