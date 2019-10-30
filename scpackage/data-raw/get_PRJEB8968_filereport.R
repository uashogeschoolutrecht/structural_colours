library(usethis)
system('wget "https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=PRJEB8968&result=read_run&fields=study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,tax_id,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,sra_ftp,sra_galaxy,cram_index_ftp,cram_index_galaxy&download=txt"')
filepath = "./filereport?accession=PRJEB8968&result=read_run&fields=study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,tax_id,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted"
filereport = read.csv(filepath, sep = "\t")
usethis::use_data(filereport)
system('rm "./filereport?accession=PRJEB8968&result=read_run&fields=study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,tax_id,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted"')
