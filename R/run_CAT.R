#' This function runs CAT on input contigs and creates the output dir at specified location. Database download included.
#'
#' @param samples_dir Absolute path to samples directory
#' @param contigpath Absolute path to the contigs fasta file
#' @param outname Basename for folder with output files
#'
#' @return
#' @export
#'
#' @examples
run_CAT = function(samples_dir, contigpath, outname){
  #
  #running CAT
  cmd = paste0("mkdir ", samples_dir, "/CAT")
  system(cmd)

  old_wd = getwd()
  setwd(paste0(samples_dir, "/CAT/"))

  #check if database has been downloaded
  if (length(grepl("CAT_prepare", list.files(paste0(samples_dir, "/CAT/")))) == 0){
    print("Downloading NCBI nr database for CAT. This can take a while. About 250 Gb of free space is required, the tar file will be removed.")
    cmd = paste0("wget tbb.bio.uu.nl/bastiaan/CAT_prepare/CAT_prepare_20190719.tar.gz -P ", samples_dir, "/CAT",
                 " && tar -xvzf ", samples_dir, "/CAT/CAT_prepare_20190719.tar.gz -C ", samples_dir, "/CAT/")
    system(command = cmd)
    cmd = paste0("rm -rf ", samples_dir, "/CAT/CAT_prepare_20190719.tar.gz")
    system(command = cmd)
  } else {
    print("NCBI nr database has been found, nothing will be downloaded.")
  }

  cmd = paste0("mkdir ", samples_dir, "/CAT/", outname)
  system(cmd)

  setwd(paste0(samples_dir, "/CAT/", outname))

  cmd = paste0("/CAT-5.0.3/CAT_pack/CAT contigs -c ", contigpath, " -d ", samples_dir, "/CAT/CAT_prepare_20190719/2019-07-19_CAT_database ", "-t ",
               samples_dir, "/CAT/CAT_prepare_20190719/2019-07-19_taxonomy")
  print(cmd)
  system(cmd)

  #creating named taxonoym file
  cmd = paste0("/CAT-5.0.3/CAT_pack/CAT add_names -i ", samples_dir, "/CAT/",
               outname, "/out.CAT.contig2classification.txt -o ", samples_dir, "/CAT/", outname,
               "/taxonomy.txt -t ", samples_dir, "/CAT/CAT_prepare_20190719/2019-07-19_taxonomy --only_official --exclude_scores")
  system(cmd)

  setwd(old_wd)
}
