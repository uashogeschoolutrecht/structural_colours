source("/home/rstudio/scpackage/R/get_data_ebi.R")

sc_accessions = c("MGYS00000991", "MGYS00005036", "MGYS00002322", "MGYS00003351")
for (sc_acc in sc_accessions){
  md5 = get_data_ebi(sc_acc, "~/data/geodescent/sc_samples")
  write(md5, file = paste0("~/data/geodescent/sc_samples/md5_", sc_acc, ".txt"))
}

save.image(file = "~/workspace_download")
