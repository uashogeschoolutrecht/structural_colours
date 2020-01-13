source("/home/rstudio/scpackage/R/get_MGYS00000991.R")
source("/home/rstudio/scpackage/R/get_MGYS00000974.R")
source("/home/rstudio/scpackage/R/get_MGYS00005036.R")
source("/home/rstudio/scpackage/R/get_filereport.R")
source("/home/rstudio/scpackage/R/get_metadata.R")
library(dplyr)

##### Loading data -----------------------------------------------------------
MGYS00000991_meta = get_MGYS00000991()
MGYS00005036_meta = get_MGYS00005036()
MGYS00002322_meta = get_metadata("MGYS00002322") %>% dplyr::filter(is.na(X) == FALSE)
MGYS00003351_meta = get_metadata("MGYS00003351")

#x wastewater with sprf
MGYS00002322_report = get_filereport(url = "https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=PRJNA413894&result=read_run&fields=study_accession,sample_accession,sra_md5,secondary_sample_accession,experiment_accession,run_accession,tax_id,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,sra_ftp,sra_galaxy,cram_index_ftp,cram_index_galaxy&download=txt",
                                     acc = "PRJNA413894")
#MGYS00005036 urban
MGYS00005036_report = get_filereport(url = "https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=PRJNA415974&result=read_run&fields=study_accession,sample_accession,sra_md5,secondary_sample_accession,experiment_accession,run_accession,tax_id,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,sra_ftp,sra_galaxy,cram_index_ftp,cram_index_galaxy&download=txt",
                                     acc = "PRJNA415974")
#MGYS00000991 arctic
MGYS00000991_report = get_filereport(url = "https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=PRJEB14154&result=read_run&fields=study_accession,sample_accession,sra_md5,secondary_sample_accession,experiment_accession,run_accession,tax_id,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,sra_ftp,sra_galaxy,cram_index_ftp,cram_index_galaxy&download=txt",
                                     acc = "PRJEB14154")
#MGYS00003351 china wastewater PRJEB22134
MGYS00003351_report = get_filereport(url = "https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=PRJEB22134&result=read_run&fields=study_accession,sample_accession,sra_md5,secondary_sample_accession,experiment_accession,run_accession,tax_id,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,sra_ftp,sra_galaxy,cram_index_ftp,cram_index_galaxy&download=txt",
                                     acc = "PRJEB22134")

##### -------------------------------------------------------------------------------

##### Combining metadata ------------------------------------------------------------
samples_meta = rbind.fill(MGYS00003351_meta, MGYS00002322_meta, MGYS00000991_meta, MGYS00005036_meta)
samples_report = rbind.fill(MGYS00002322_report, MGYS00003351_report, MGYS00000991_report, MGYS00005036_report)
# check if for all metadata samples sequencing data was available
if (all(samples_meta$accession %in% samples_report$secondary_sample_accession) == TRUE) {
  print("Tested: Sequencing data is available for all samples with metadata")
} else {
  print("WARNING: no sequencing data detected for some of the samples with metadata supplied")
}

samples_report_with_metadata = samples_report %>%
  dplyr::filter(secondary_sample_accession %in% samples_meta$accession) %>%
  dplyr::rename(accession = secondary_sample_accession)

metadata = dplyr::inner_join(x = samples_report_with_metadata, y = samples_meta, by = c("accession"))
write.csv(metadata, file = "~/scpackage/data/metadata", quote = FALSE)

##### Downloading SRA files-------------------------------------------------------------------------------
for (acc in metadata$run_accession){
  system(paste0("bash /home/rstudio/scpackage/inst/get_sc_data.sh -a ", acc))
  system(paste0("mv ", acc, "* /home/rstudio/data/geodescent/sc_samples"))
}

system("rm -rf ~/ncbi")
