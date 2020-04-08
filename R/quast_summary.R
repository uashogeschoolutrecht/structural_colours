quast_summary = function(quast_parent_dir) {
  reports = c()
  quast_dirs = list.files(quast_parent_dir)
  quast_tsv_paths = paste0(quast_parent_dir, "/", quast_dirs, "/report.tsv")
  for (i in seq_along(quast_tsv_paths)) {
    path = quast_tsv_paths[i]
    name = quast_dirs[i]
    report = read.csv(file = path,
             header = FALSE,
             sep = '\t')
    vals = as.character(report$V2)
    vals[1] = name
    report$V2 = vals
    reports = c(reports, report)
  }
  header = as.character(reports[[1]])
  for (i in seq(2, length(reports), 2)) {
    record = unlist(reports[i])
    header = cbind(header, record)
  }
  quast_summary = t(header)
  return(quast_summary)
}
