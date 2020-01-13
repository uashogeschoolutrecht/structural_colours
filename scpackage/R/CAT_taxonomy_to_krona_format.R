CAT_taxonomy_to_krona_format = function(CAT_file, outfile){
  file = read.csv(file = CAT_file, sep = "\t")
  krona_cols = file[,-c(3,4,5)]
  krona_cols$X..contig = 1
  write.table(krona_cols, file = outfile, sep = "\t",
              col.names = FALSE, row.names = FALSE, quote = FALSE)
}

CAT_file = "/home/rstudio/data/official_named_noscore_tax.txt"
outfile = "/home/rstudio/data/krona_tax_IR1.txt"






