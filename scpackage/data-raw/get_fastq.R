#' This function uses the fastq_ftp col from the filereport to download the fastq files of the study.
#'
#' @param filereport Data frame of filereport, only column used is fastq_ftp. This filereport can be made using get_filereport().
#' @param outdir Directory to store output, full path. Will be made by script (mkdir).
#'
#' @return The fastq files will be moved to the supplied output directory.
#' @export
#'
#' @examples get_fastq(filereport = filereport,
#' outdir = "/home/rstudio/data/geodescent/samples/TEST")
get_fastq = function(filereport, outdir) {
  for (urls in filereport$fastq_ftp){
    #parsing paths
    x = strsplit(urls, split = ';')
    x = x[[1]]
    x1_f = strsplit(x[1], '/')
    last = length(x1_f[[1]])
    x1_f = x1_f[[1]][last]
    x2_f = strsplit(x[2], '/')
    x2_f = x2_f[[1]][last]
    #downloading files
    command1 = paste("wget", x[1])
    command2 = paste("wget", x[2])
    system(command1)
    system(command2)

    #creating output dir
    command = paste0("mkdir ", outdir)
    system(command)

    #moving files
    command3 = paste("mv", x1_f, outdir)
    command4 = paste("mv", x2_f, outdir)
    system(command3)
    system(command4)
  }
}


#accs = list()
#for (urls in filereport$fastq_ftp){
#  x = strsplit(urls, split = ';')
#  x = x[[1]]
#  x = strsplit(x, '/')
#  x = x[[1]]
#  x = x[6]
#  print(x)
#  accs = append(accs, x)
#}
#acs = unlist(accs)
#write(acs, file = "data/acc_list")
