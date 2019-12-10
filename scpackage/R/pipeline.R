run_sc_pipeline = function(samples_dir) {
  ##### Loading data -----------------------------------------------------------
  MGYS00000991_meta = get_MGYS00000991()
  MGYS00005036_meta = get_MGYS00005036()
  MGYS00002322_meta = get_metadata("MGYS00002322") %>% dplyr::filter(is.na(X) == FALSE)
  MGYS00003351_meta = get_metadata("MGYS00003351")

  #x wastewater with sprf
  MGYS00002322_report = get_filereport(url = "https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=PRJNA413894&result=read_run&fields=study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,tax_id,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,sra_ftp,sra_galaxy,cram_index_ftp,cram_index_galaxy&download=txt",
                                       acc = "PRJNA413894")
  #MGYS00005036 urban
  MGYS00005036_report = get_filereport(url = "https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=PRJNA415974&result=read_run&fields=study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,tax_id,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,sra_ftp,sra_galaxy,cram_index_ftp,cram_index_galaxy&download=txt",
                                       acc = "PRJNA415974")
  #MGYS00000991 arctic
  MGYS00000991_report = get_filereport(url = "https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=PRJEB14154&result=read_run&fields=study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,tax_id,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,sra_ftp,sra_galaxy,cram_index_ftp,cram_index_galaxy&download=txt",
                                       acc = "PRJEB14154")
  #MGYS00003351 china wastewater PRJEB22134
  MGYS00003351_report = get_filereport(url = "https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=PRJEB22134&result=read_run&fields=study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,tax_id,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,sra_ftp,sra_galaxy,cram_index_ftp,cram_index_galaxy&download=txt",
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

  #getting fastq files
  print("Note: Downloading fastq files, this can take days.")
  get_fastq(filereport = metadata,
            outdir = samples_dir)
  print("Note: A silent error may occur when the connection is refused by ebi. Please check that all files are downloaded")
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
  header = c("megahit_outname", "read_1", "read_2")

  #defining (trimmed!) samples to use
  samples = list.files(path = paste0(samples_dir, "/trimmed"))
  samples_paths = paste0(samples_dir, "/trimmed/", samples)

  # running assembly tool on the trimmed fastq files
  for (i in seq_along(samples_paths)) {
    path = samples_paths[i]
    name = samples[i]
    if (grepl("_1P.f", path) == TRUE) {
      path2 = str_replace(path, pattern = "_1P.f", replacement = "_2P.f")
      name1 = str_replace(name, pattern = "_1P", replacement = "")
      outname = paste0("megahit_", name1)
      run_megahit(
        PE = T,
        script_path = "inst/megahit.sh",
        r1 = path,
        r2 = path2,
        outdir = outdir,
        outname = outname
      )
      io_log = c(outname, path, path2)
    } else {
      if (grepl("_2P.f", path) == FALSE) {
        if (grepl("_1U", path) == FALSE) {
          if (grepl("_2U", path) == FALSE) {
            outname = paste0("megahit_", name)
            run_megahit(
              PE = F,
              script_path = "inst/megahit.sh",
              r1 = path,
              outdir = outdir,
              outname = outname
            )
            io_log = c(outname, path, "NA")
          }
        }
      }
    }
    header = rbind(header, io_log)
  }

  # log for use in bbmap
  megahit_io = unique.data.frame(header[-1,])
  colnames(megahit_io) = header[1,]

  ##### -------------------------------------------------------------------------------

  ##### Assembly quality assessment -----------------------------------------------------
  # using quast the assemblies stats can be calulated, using bbmap the coverage of each contig.

  # getting paths to contigs
  samples = list.files(path = paste0(samples_dir, "/megahit"))
  contig_paths = paste0(samples_dir, "/megahit/", samples, "/final.contigs.fa")

  # creating quast output directory
  command = paste0("mkdir ", samples_dir, "/quast")
  system(command)

  # running quast
  for (i in seq_along(contig_paths)) {
    path = contig_paths[i]
    name = samples[i]
    run_quast(filepath = path,
              outdir = paste0(samples_dir, "/quast/", "quast_", name))
  }

  # collecting basic stats assemblies
  quast_parent_dir = paste0(samples_dir, "/quast")
  quast_summary_stats = quast_summary(quast_parent_dir = quast_parent_dir)

  #create bbmap main outdir
  command = paste0("mkdir ", samples_dir, "/bbmap")
  system(command)

  # running bbmap
  logs = list()
  refs = list()
  for (megahit_run in 1:nrow(megahit_io)) {
    record = megahit_io[megahit_run,]
    if (record["read_2"] == "NA") {
      #run SE
      log = run_bbmap(mode = "SE",
                read1 = record["read_1"],
                ref = paste0(samples_dir, "/megahit/", record["megahit_outname"], "/final.contigs.fa"),
                outdir = paste0(samples_dir, "/bbmap/bbmap_", record["megahit_outname"])
                )
      logs = append(logs, list(log))
      refs = append(refs, record["megahit_outname"])
    } else {
      #run PE
      log = run_bbmap(mode = "PE",
                read1 = record["read_1"],
                read2 = record["read_2"],
                ref = paste0(samples_dir, "/megahit/", record["megahit_outname"], "/final.contigs.fa"),
                outdir = paste0(samples_dir, "/bbmap/bbmap_", record["megahit_outname"])
      )
      logs = append(logs, list(log))
      refs = append(refs, record["megahit_outname"])
    }
  }

  #parsing logs
  #initialize df
  df = c("a","a","a","a","a","a","a","a","a","a","a","a","a")
  for (i in seq(1, length(refs))) {
    log = unlist(logs[i])
    ref = unlist(refs[i])
    for (line in log) {
      if (grepl("Reads:", line) == TRUE) {
        start_results = match(line, log)
      }
      if (grepl("Percent of reference bases covered:", line) == TRUE) {
        end_results = match(line, log)
      }
    }
    results = log[start_results:end_results]
    header = c("Reference:", ref)
    for (line in results) {
      line = strsplit(line, split = '\t')
      header = rbind(header, unlist(line))
      record = t(header)
      colnames(record) = NULL
      rownames(record) = NULL
    }
    df = rbind(df, record)
  }
  bbmap_summary_stats = unique.data.frame(df[-1,])
  #Note: grinder 10x coverage setting from control reads can be seen in bbmap output!
  ##### -----------------------------------------------------------------------------------

  ##### Binning ------------------------------------------------------------------------
  # to be able to get an idea from which taxonomic group a hit on a contig is, the contigs will be binned.
  # bbmap output can be used to make the tool more sensitive
  logs_header = c("Input:", "Bins:", "Percentage binned:")

  command = paste0("mkdir ", samples_dir, "/metabat2")
  system(command)

  megahit_dirs = list.files(path = paste0(samples_dir, "/megahit"))
  contig_paths = paste0(samples_dir, "/megahit/", megahit_dirs, "/final.contigs.fa")

  for (i in seq(1, length(megahit_dirs))) {
    #get paths
    megahit_dir = megahit_dirs[i]
    contig_path = contig_paths[i]
    sorted_bam_path = paste0(samples_dir, "/bbmap/bbmap_", megahit_dir, "/mapped_sorted.bam")
    #run metbata
    metabat_log = run_metabat2(metabat_script = "inst/metabat2.sh",
                 s_bam = sorted_bam_path,
                 fasta = contig_path
    )
    # create output folder
    command = paste0("mkdir ", samples_dir, "/metabat2/", megahit_dir)
    system(command)
    # move output files
    command = paste0("mv mapped.* ", samples_dir, "/metabat2/", megahit_dir)
    system(command)
    #writing log
    log = as_text(metabat_log$stdout)
    bin = log[grepl("formed.", log)]
    if (length(log[grepl("contigs were binned.", log)]) == 0) {
      perc = NA
    } else {
      perc = log[grepl("contigs were binned.", log)]
      perc = str_sub(perc, start = 12, end = nchar(perc))
    }
    new_log_record = c(megahit_dir, bin, perc)
    logs_header = rbind(logs_header, new_log_record)
  }
  metabat_log = logs_header
  ##### ----------------------------------------------------------------------------------------------------

  ##### Taxonomic assignment of whole samples and bins -----------------------------------------------------
  # kraken2
  megahit_dirs = list.files(path = paste0(samples_dir, "/megahit"))
  contig_paths = paste0(samples_dir, "/megahit/", megahit_dirs, "/final.contigs.fa")

  for (i in seq(1, length(megahit_dirs))) {
    #get paths
    megahit_dir = megahit_dirs[i]
    contig_path = contig_paths[i]

    basename = str_replace(megahit_dir, pattern = "megahit_trimmed_", replacement = "")
    basename = str_split(basename, pattern = ".f")[[1]][1]

    run_kraken2(samples_dir = samples_dir,
                outname = basename,
                threads = 15,
                contig = contig_path)
  }
  ##### -----------------------------------------------------------------------------------------------------

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
source("/home/rstudio/scpackage/R/get_metadata.R")
source("/home/rstudio/scpackage/R/get_fastq.R")
source("/home/rstudio/scpackage/R/grinder.R")
source("/home/rstudio/scpackage/R/run_fastqc.R")
source("/home/rstudio/scpackage/R/fastqc_multisummary.R")
source("/home/rstudio/scpackage/R/run_trimmomatic.R")
source("/home/rstudio/scpackage/R/run_megahit.R")
source("/home/rstudio/scpackage/R/run_quast.R")
source("/home/rstudio/scpackage/R/quast_summary.R")
source("/home/rstudio/scpackage/R/run_bbmap.R")
source("/home/rstudio/scpackage/R/run_metabat2.R")
run_sc_pipeline(samples_dir = "/home/rstudio/data/geodescent/test_samples")
