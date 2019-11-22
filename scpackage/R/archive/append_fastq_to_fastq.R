#' This function can be used to combine two fastq files, for instance to spike a file.
#'
#' @param file_one Absolute path to a fastq file to be combined
#' @param file_two Absolute path to a fastq file to be combined, can be gzipped
#' @param outfile Path to new file, will be created by script
#'
#' @return A file with the concatenated sequences will be generated at the specified output path
#' @export
#'
#' @examples
append_fastq_to_fastq = function(file_one, file_two, outdir, outname){
  command = paste0("cp ", file_two," ", outdir)
  system(command)
  splitted = strsplit(file_two, '/')
  filename = splitted[[1]]
  len = length(filename)
  filename = filename[len]
  if (grepl(".gz", filename) == TRUE){
    command = paste0("gunzip ", outdir, "/", filename)
    new_name = strsplit(filename, '.g')
    new_name = new_name[[1]]
    len = length(new_name)
    new_name = new_name[len-1]
    system(command)

    command = paste0("cat ", file_one, " >> ", outdir, "/", new_name)
    system(command)
    command = paste0("mv ", outdir, "/", new_name, " ", outdir, "/", outname)
    system(command)
  } else {
    command = paste0("cat ", file_one, " >> ", outdir, "/", filename)
    system(command)
    command = paste0("mv ", outdir, "/", filename, " ", outdir, "/", outname)
  }
}
