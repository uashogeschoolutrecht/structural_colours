run_kraken2 = function(samples_dir, outname, threads, contig) {
  command = paste0("mkdir -p ", samples_dir, "/kraken/", outname)
  system(command)
  if (length(grepl("kraken_db", list.files(paste0(samples_dir, "/kraken/")))) == 0) {
    print("Downloading kraken database, this can take about an hour")
    command = paste0("kraken2-build --standard --threads ", threads, " --db ",
                     samples_dir, "/kraken/kraken_db")
    system(command)

    #add plant and protozoa library
    print("Adding plant and protozoa libraries to the kraken2 database")
    command = paste0("kraken2-build --download-library plant --db ", samples_dir, "/kraken/kraken_db", " && kraken2-build --download-library protozoa --db ", samples_dir, "/kraken/kraken_db")
    print(command)
    system(command)
  } else {
    print("Database dir kraken/kraken_db detected, database will not be downloaded")
  }

  print(paste0("Running kraken2 on '", contig, "'" ))
  command = paste0("kraken2 --db ", samples_dir, "/kraken/kraken_db ", contig,
                   " --report ", samples_dir, "/kraken/", outname, "/kraken_out.txt", " --report-zero-counts --use-names")
  system(command)
}
