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
  grinder(reference_file = "/home/$USER/scpackage/inst/extdata/GCA_002277835.1_ASM227783v1_genomic.fna",
          outname = "control_IR1",
          outdir = samples_dir,
          coverage = 10)
  # removing ranks file, we used equal distribution of contigs.
  command = paste0("rm ", samples_dir, "/control_IR1-ranks.txt")
  system(command)
  ##### ----------------------------------------------------------------------------------------

  ##### FastQC quality control ------------------------------------------------
  samples = list.files(path = samples_dir)
  samples_paths = paste0(samples_dir, "/", samples)
  for (sample_path in samples_paths) {
    run_fastqc(sample_path)
  }
  command = paste0("mkdir -p ", samples_dir, "/fastqc/untrimmed && mv ", samples_dir, "/*fastqc.* ", samples_dir, "/fastqc/untrimmed")
  system(command)

  fastqc_plot_untrimmed = fastqc_multisummary(results_dir = paste0(samples_dir, "/fastqc/untrimmed"))
  ##### -----------------------------------------------------------------------

  ##### Quality trimming -----------------------------------------------------------------------
  # the fastq files will be trimming removing very low quality parts
  trimmomatic_stats = list()
  trimmomatic_files = list()

  #creating output folder
  command = paste0("mkdir ", samples_dir, "/trimmed")
  system(command)

  for (i in seq_along(samples_paths)) {
    path = samples_paths[i]
    name = samples[i]
    if (grepl("_1.f", path) == TRUE){
      path2 = str_replace(path, pattern = "_1.f", replacement = "_2.f")
      name1 = str_replace(name, pattern = "_1", replacement = "")
      trim_stat = run_trimmomatic(mode = "PE",
                      f1 = path,
                      f2 = path2,
                      prefix = paste0("trimmed_", name1))
      trimmomatic_stats = append(trimmomatic_stats, trim_stat)
      name2 = str_replace(name, pattern = "_1", replacement = "*(PE)")
      trimmomatic_files = append(trimmomatic_files, name2)
    } else {
      if (grepl("_2.f", path) == FALSE){
        if (grepl("fastqc", path) == FALSE){
          trim_stat = run_trimmomatic(mode = "SE",
                                      f1 = path,
                                      prefix = paste0("trimmed_", name))
          trimmomatic_stats = append(trimmomatic_stats, trim_stat)
          trimmomatic_files = append(trimmomatic_files, name)
        }
      }
    }
  }

  #moving trimmed files
  command = paste0("mv ", "trimmed_* ", samples_dir, "/trimmed")
  system(command)

  #combining log lists into data frame
  trimmomatic_stats = unlist(trimmomatic_stats)
  trimmomatic_files = unlist(trimmomatic_files)
  trimmomatic_log = cbind(trimmomatic_files, trimmomatic_stats)
  ##### ----------------------------------------------------------------------------------

  ##### FastQC quality control 2: after trimming ------------------------------------------------
  samples = list.files(path = paste0(samples_dir, "/trimmed"))
  samples_paths = paste0(samples_dir, "/trimmed/", samples)
  for (sample_path in samples_paths) {
    if (grepl("_1U", sample_path) == FALSE){
      if (grepl("_2U", sample_path) == FALSE){
        run_fastqc(sample_path)
      }
    }
  }
  command = paste0("mkdir -p ", samples_dir, "/fastqc/trimmed && mv ", samples_dir, "/trimmed/*fastqc.* ", samples_dir, "/fastqc/trimmed")
  system(command)

  fastqc_plot_trimmed = fastqc_multisummary(results_dir = paste0(samples_dir, "/fastqc/trimmed"))
  ##### -----------------------------------------------------------------------

  ##### Assembly -------------------------------------------------------------------------
  # to create longer contigs for less fragmented genes / better taxonomic assignment
  # creating output path
  outdir = paste0(samples_dir, "/megahit")

  #defining (trimmed!) samples to use
  samples = list.files(path = paste0(samples_dir, "/trimmed"))
  samples_paths = paste0(samples_dir, "/trimmed/", samples)

  # running assembly tool on the trimmed fastq files
  for (i in seq_along(samples_paths)) {
    path = samples_paths[i]
    name = samples[i]
    if (grepl("_1P.f", path) == TRUE){
      path2 = str_replace(path, pattern = "_1P.f", replacement = "_2P.f")
      name1 = str_replace(name, pattern = "_1P", replacement = "")
      run_megahit(PE = T,
                  script_path = "inst/megahit.sh",
                  r1 = path,
                  r2 = path2,
                  outdir = outdir,
                  outname = paste0("megahit_", name1)
      )
    } else {
      if (grepl("_2P.f", path) == FALSE){
        if (grepl("_1U", path) == FALSE){
          if (grepl("_2U", path) == FALSE){
          run_megahit(PE = F,
                      script_path = "inst/megahit.sh",
                      r1 = path,
                      outdir = outdir,
                      outname = paste0("megahit_", name)
          )
          }
        }
      }
    }
  }
  ##### -------------------------------------------------------------------------------

  ##### Assembly quality assessment -----------------------------------------------------
  # using metaquast the assemblies stats can be calulated, using bbmap the coverage of each contig.

  ##### -----------------------------------------------------------------------------------

}



library("rjsonapi")
library("foreach")
library(parallel)
library(MASS)
library(ggplot2)
library(stringr)
library(sys)
source("/home/rstudio/scpackage/R/get_MGYS00000991.R")
source("/home/rstudio/scpackage/R/get_MGYS00000974.R")
source("/home/rstudio/scpackage/R/get_MGYS00005036.R")
source("/home/rstudio/scpackage/R/get_filereport.R")
source("/home/rstudio/scpackage/R/get_fastq.R")
source("/home/rstudio/scpackage/R/grinder.R")
source("/home/rstudio/scpackage/R/run_fastqc.R")
source("/home/rstudio/scpackage/R/fastqc_multisummary.R")
source("/home/rstudio/scpackage/R/run_trimmomatic.R")
source("/home/rstudio/scpackage/R/run_megahit.R")
run_sc_pipeline(samples_dir = "/home/rstudio/data/geodescent/test_samples")
