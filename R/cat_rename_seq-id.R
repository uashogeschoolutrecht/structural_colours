#' Concatenate binned contigs into one file per sample and add samplename and bin name to the headers.
#'
#' @param bin_dirs_parent_dir String, path to directory containing directories with bins (metabat2 folder in pipeline function output)
#'
#' @return A file with the concatenated sequences with renamed headers is created in each sample folder. (total_(samplename).fa)
#' @export
#'
#' @examples
#'\dontrun{
#' metabat_dir = paste0(samples_dir, "/metabat2")
#' cat_rename_seq_id(bin_dirs_parent_dir = metabat_dir)
#' }
cat_rename_seq_id = function(outdir, sample_accession) {

    bin_dir = paste0(outdir, "/metabat2/", sample_accession)

    outfile = paste0(outdir,
                     "/metabat2/",
                     sample_accession,
                     "/total_",
                     sample_accession,
                     ".fa")

    if (file.exists(outfile)){
      print("Deleting already present copy of output file before re-running.")
      cmd = paste0("rm ", outfile)
      system(cmd)
    }


    #get paths to bins, only files with .fa suffix
    sample_bin_paths = paste0(outdir,
                              "/metabat2/",
                              sample_accession,
                              "/",
                              list.files(paste0(outdir, "/metabat2/", sample_accession)))[grepl(pattern = '*.fa',
                                                                                              paste0(
                                                                                                outdir, "/metabat2",
                                                                                                "/",
                                                                                                sample_accession,
                                                                                                "/",
                                                                                                list.files(paste0(outdir, "/metabat2/", sample_accession))
                                                                                              ))]
    for (bin_path in sample_bin_paths) {

      bin_name = strsplit(bin_path, split = 'mapped.metabat.')[[1]][2]
      bin_name = substring(bin_name, 1, nchar(bin_name) - 3)

      seq_id = paste0(sample_accession, "_b:", bin_name)

      command = paste0("sed 's/>/",
                       ">",
                       seq_id,
                       "_",
                       "/' ",
                       bin_path,
                       " >> ",
                       outfile)
      system(command)
    }
  }
