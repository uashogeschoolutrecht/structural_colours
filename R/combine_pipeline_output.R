# combine_pipeline_output = function(pipeline_output_dir, metadata_rds) {
#   # loading in the metadata
#   metadata = readRDS(metadata_rds)
#
#   #subset for testing
#   metadata = metadata[2:2,]
#   metadata$run_accession = c("ERR833291")
#
#
#   run_accessions = list.files(path = paste0(pipeline_output_dir, "/quast/"))
#
#   run_accessions = run_accessions[1]
#
#   # adding quast transposed report tsv per sample to metadata
#   quast_total = data.frame()
#   # reADING FILES
#   for (run_accession in run_accessions){
#     quast_file = paste0(pipeline_output_dir, "/quast/", run_accession, "/transposed_report.tsv")
#     quast_output = read.delim(file = quast_file, header = TRUE, sep = "\t")
#     quast_output$run_accession = run_accession
#     quast_total = rbind(quast_total, quast_output)
#   }
#   metadata = join(metadata, quast_total, type = "left")
#
#
#   #adding prokka
#   prokka_total = data.frame()
#   for (run_accession in run_accessions){
#     prokka_file = paste0(pipeline_output_dir, "/prokka/", run_accession, "/", run_accession, ".tsv")
#     prokka_output = read.delim(file = prokka_file, header = TRUE, sep = "\t")
#     prokka_output$run_accession = run_accession
#     prokka_total = rbind(prokka_total, prokka_output)
#   }
#   metadata = join(metadata, prokka_total)
#
#
#   # adding CAT taxonomy
#   tax_total = data.frame()
#   for (run_accession in run_accessions){
#     tax_file = paste0(pipeline_output_dir, "/CAT/", run_accession, "/taxonomy.txt")
#     tax_output = read.delim(file = tax_file, header = TRUE, sep = "\t")
#     tax_output$run_accession = run_accession
#     tax_total = rbind(tax_total, tax_output)
#   }
#
#   metadata = join(metadata, tax_total)
#
#
#   #devtools::install_github("rstudio/sparklyr")
#   spark_install()
#   library(sparklyr)
#   sc <- spark_connect(master = "local")
#
#   readr::write_csv(tax_total, path = "~/tax_ERR83291.csv")
#
#
#
#   metadata_291 = sparklyr::spark_read_csv(sc = sc, name = "metadata_291",
#                            path = "~/metadata_ERR83291.csv")
#   tax_291 = sparklyr::spark_read_csv(sc = sc, name = "tax_291",
#                                           path = "~/tax*.csv")
#   totaldata_305 = sparklyr::spark_read_csv(sc = sc, name = "totaldata_305",
#                                            path = "~/*305.csv")
#
#   x = left_join(tax_291, metadata_291)
#   x %>% filter(superkingdom != "Bacteria")
#
#
#
#   metadata = merge(metadata, tax_total)
#
#
#   saveRDS(metadata, "~/metadata")
#
# }
#
# library(dplyr)
# library(plyr)
# combine_pipeline_output(pipeline_output_dir = "/data/test_singlep",
#                         metadata_rds = "/data/MGYS00000410_metadata.RDS")
