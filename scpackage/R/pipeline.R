run_sc_pipeline = function(samples_dir) {
  ##### Loading data -----------------------------------------------------------
  MGYS00000991_meta = get_MGYS00000991()
  MGYS00000974_meta = get_MGYS00000974()
  MGYS00005036_meta = get_MGYS00005036()
  #MGYS00000974 ocean cruise
  MGYS00000974_report = get_filereport(url = "https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=PRJEB8968&result=read_run&fields=study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,tax_id,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,sra_ftp,sra_galaxy,cram_index_ftp,cram_index_galaxy&download=txt",
                                       acc = "PRJEB8968")
  #MGYS00005036 urban
  MGYS00005036_report = get_filereport(url = "https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=PRJNA415974&result=read_run&fields=study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,tax_id,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,sra_ftp,sra_galaxy,cram_index_ftp,cram_index_galaxy&download=txt",
                                       acc = "PRJNA415974")
  #MGYS00000991 arctic
  MGYS00000991_report = get_filereport(url = "https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=PRJEB14154&result=read_run&fields=study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,tax_id,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,sra_ftp,sra_galaxy,cram_index_ftp,cram_index_galaxy&download=txt",
                                       acc = "PRJEB14154")
  #getting fastq files
  print("Note: Downloading fastq files, this can take days.")
  get_fastq(filereport = MGYS00000974_report,
            outdir = samples_dir)
  get_fastq(filereport = MGYS00005036_report,
            outdir = samples_dir)
  get_fastq(filereport = MGYS00000991_report,
            outdir = samples_dir)
  print("Note: A silent error may occur when the connection is refused by ebi. Please check that all files are downloaded")
  ##### -------------------------------------------------------------------------------
  
  ##### Combining metadata ------------------------------------------------------------
  samples_meta = rbind.fill(MGYS00000974_meta, MGYS00000991_meta, MGYS00005036_meta)
  samples_report = rbind.fill(MGYS00000974_report, MGYS00000991_report, MGYS00005036_report)
  # check if for all metadata samples sequencing data was available
  if (all(samples_meta$accession %in% samples_report$secondary_sample_accession) == TRUE) {
    print("Tested: Sequencing data is available for all samples with metadata")
  } else {
    print("WARNING: no sequencing data detected for some of the samples with metadata supplied")
  }
  ##### -------------------------------------------------------------------------------
  
  ##### Create control sample -----------------------------------------------------------
  # to check the validity of processing steps and later blast results IR1 will be used as positive control
  grinder_outdir = paste0(samples_dir, "/grinder_IR1")
  grinder(reference_file = "/home/$USER/scpackage/inst/extdata/GCA_002277835.1_ASM227783v1_genomic.fna",
          outname = "control_IR1",
          outdir = grinder_outdir,
          coverage = 10)
  #moving output files
  command = paste0("mv ", grinder_outdir, "/control_IR1-reads.fastq",
                   " ", samples_dir)
  system(command)
  command = paste0("rm -rf ", grinder_outdir)
  system(command)
  print("Note: The grinder ouput fastq file has been moved to the samples directory to include it in processing")
  ##### ----------------------------------------------------------------------------------------
  
  ##### Quality trimming -----------------------------------------------------------------------
  # the fastq files will be trimming removing very low quality parts
  samples = list.files(path = samples_dir)
  samples_paths = paste0(samples_dir, "/", samples)
  for (i in seq_along(samples_paths)) {
    path = samples_paths[i]
    name = samples[i]
    name = substr(name, 1, 9)
    if (grepl("_1.f", path) == TRUE){
      path2 = str_replace(path, pattern = "_1.f", replacement = "_2.f")
      run_trimmomatic(mode = "PE",
                      f1 = path,
                      f2 = path2,
                      prefix = name)
    } else {
      print(path)
      run_trimmomatic(mode = "SE",
                      f1 = path,
                      prefix = name)
    }
  }
  
}


library("rjsonapi")
library("foreach")
library(parallel)
library(doParallel)
library(MASS)
source("/home/rstudio/scpackage/R/get_MGYS00000991.R")
source("/home/rstudio/scpackage/R/get_MGYS00000974.R")
source("/home/rstudio/scpackage/R/get_MGYS00005036.R")
source("/home/rstudio/scpackage/R/get_filereport.R")
source("/home/rstudio/scpackage/R/get_fastq.R")
source("/home/rstudio/scpackage/R/grinder.R")
source("/home/rstudio/scpackage/R/run_trimmomatic.R")
run_sc_pipeline(samples_dir = "/home/rstudio/data/geodescent/samples2")
