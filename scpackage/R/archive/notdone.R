
library(dplyr)
out_dir = "/home/rstudio/research_drive/geodescent/samples/MGYS00005036/"

load(file = "/home/rstudio/scpackage/data/filereport_PRJNA415974.rda")
load(file = "/home/rstudio/scpackage/data/MGYS00005036.rda")

x = filereport_PRJNA415974$fastq_ftp %>%
  as.character() %>%
  strsplit(, split = ';')

accs = filereport_PRJNA415974$run_accession %>%
  as.character()

for (i in 1:length(x)){
  acc = accs[i]
  fr = x[[i]][1]
  rr = x[[i]][2]
  command=paste0("wget ",fr, " && wget ", rr, " && mv ", acc, "* ", out_dir)
  system(command)
}
