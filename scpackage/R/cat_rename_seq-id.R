cat_rename_seq_id = function(bin_dirs_parent_dir){
  bin_dirs = list.files(path = bin_dirs_parent_dir)
  for (i in seq(length(bin_dirs))){

    samplename = bin_dirs[i]
    bin_dir = bin_dirs[i]

    outfile = paste0(bin_dirs_parent_dir, "/", bin_dir, "/total_", samplename, ".fa")

    #get paths to bins, only files with .fa suffix
    sample_bin_paths = paste0(bin_dirs_parent_dir, "/", samplename, "/",
                              list.files(paste0(bin_dirs_parent_dir, "/", samplename)))[grepl(pattern = '*.fa', paste0(bin_dirs_parent_dir, "/", samplename, "/",
                                                                                                                    list.files(paste0(bin_dirs_parent_dir, "/", samplename))))]
    for (bin_path in sample_bin_paths) {
      bin_name = strsplit(bin_path, split = 'mapped.metabat.')[[1]][2]
      bin_name = substring(bin_name, 1, nchar(bin_name)-3)

      seq_id = paste0(samplename, "_b:", bin_name)

      command = paste0("sed 's/>/",
                       ">",
                       seq_id,
                       "_",
                       "/' ",
                       bin_path,
                       " >> ",
                       outfile
      )
      system(command)
    }
    }
}
