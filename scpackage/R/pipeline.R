#' Title
#'
#' @param samples_dir
#' @param marker_genes_fasta
#'
#' @return
#' @export
#'
#' @examples
run_sc_pipeline = function(samples_dir, marker_genes_fasta) {
  ##### Create control sample -----------------------------------------------------------
  # to check the validity of processing steps and later blast results IR1 will be used as positive control
  grinder(reference_file = "/home/$USER/scpackage/inst/extdata/GCA_002277835.1_ASM227783v1_genomic.fna",
          outname = "control_IR1",
          outdir = samples_dir,
          coverage = 10)
  # removing ranks file, used equal distribution of contigs.
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

  cmd = paste0("mkdir ", samples_dir,"/workspace_logs")
  system(cmd)
  save.image(file = paste0(samples_dir, "/workspace_logs/",
                           Sys.time(), "_workspace.RData"))
  ##### -----------------------------------------------------------------------

  ##### Quality trimming -----------------------------------------------------------------------
  # the fastq files will be trimmed removing very low quality parts
  trimmomatic_stats = list()
  trimmomatic_files = list()

  #creating output folder
  command = paste0("mkdir ", samples_dir, "/trimmed")
  system(command)

  for (i in seq_along(samples_paths)) {
    path = samples_paths[i]
    name = samples[i]
    if (grepl("_1.f", path) == TRUE){
      path2 = stringr::str_replace(path, pattern = "_1.f", replacement = "_2.f")
      name1 = stringr::str_replace(name, pattern = "_1", replacement = "")
      trim_stat = run_trimmomatic(mode = "PE",
                      f1 = path,
                      f2 = path2,
                      prefix = paste0("trimmed_", name1))
      trimmomatic_stats = append(trimmomatic_stats, trim_stat)
      name2 = stringr::str_replace(name, pattern = "_1", replacement = "*(PE)")
      trimmomatic_files = append(trimmomatic_files, name2)
      command = paste0("mv ", "trimmed_* ", samples_dir, "/trimmed")
      system(command)
    } else {
      if (grepl("_2.f", path) == FALSE){
        if (grepl("fastqc", path) == FALSE){
          trim_stat = run_trimmomatic(mode = "SE",
                                      f1 = path,
                                      prefix = paste0("trimmed_", name))
          trimmomatic_stats = append(trimmomatic_stats, trim_stat)
          trimmomatic_files = append(trimmomatic_files, name)
          command = paste0("mv ", "trimmed_* ", samples_dir, "/trimmed")
          system(command)
        }
      }
    }
  }


  #combining log lists into data frame
  trimmomatic_stats = unlist(trimmomatic_stats)
  trimmomatic_files = unlist(trimmomatic_files)
  trimmomatic_log = cbind(trimmomatic_files, trimmomatic_stats)

  save.image(file = paste0(samples_dir, "/workspace_logs/",
                           Sys.time(), "_workspace.RData"))
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

  save.image(file = paste0(samples_dir, "/workspace_logs/",
                           Sys.time(), "_workspace.RData"))
  ##### -----------------------------------------------------------------------

  ##### Assembly -------------------------------------------------------------------------
  # to create longer seqs for less fragmented genes / better taxonomic assignment
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

  save.image(file = paste0(samples_dir, "/workspace_logs/",
                           Sys.time(), "_workspace.RData"))
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

  save.image(file = paste0(samples_dir, "/workspace_logs/",
                           Sys.time(), "_workspace.RData"))
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
    basename = str_replace(megahit_dir, pattern = "megahit_trimmed_", replacement = "")
    basename = str_split(basename, pattern = ".f")[[1]][1]
    # create output folder
    command = paste0("mkdir ", samples_dir, "/metabat2/", basename)
    system(command)
    # move output files
    command = paste0("mv mapped.* ", samples_dir, "/metabat2/", basename)
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
    new_log_record = c(basename, bin, perc)
    logs_header = rbind(logs_header, new_log_record)
  }
  metabat_log = logs_header

  save.image(file = paste0(samples_dir, "/workspace_logs/",
                           Sys.time(), "_workspace.RData"))
  ##### ----------------------------------------------------------------------------------------------------



  ##### Blast  -------------------------------------------------------------------------------
  cmd = paste0("mkdir ", samples_dir, "/blast")
  system(cmd)

  #renaming adding bin and sample names to contigs to retrace
  metabat_dir = paste0(samples_dir, "/metabat2")
  cat_rename_seq_id(bin_dirs_parent_dir = metabat_dir)

  #concatenating renamed contig files for use in make blast db
  sample_dirs_metabat = paste0(metabat_dir, "/", list.files(metabat_dir))
  blast_db_fasta = paste0(samples_dir, "/blast/database.fa")
  for (metabat_sample_dir in sample_dirs_metabat){
    files = list.files(metabat_sample_dir)
    contig_file = files[grepl("total_", files)]
    contig_path = paste0(metabat_sample_dir, "/", contig_file)
    command = paste0("cat ", contig_path, " >> ", blast_db_fasta)
    system(command)
  }

  #making blast db
  makeblastdb(input = blast_db_fasta,
              outname = 'blast_database',
              outdir = paste0(samples_dir, "/blast/"),
              dbtype = 'nucl')

  #running tblastn (prot against nucl)
  blast(blast = "tblastn",
        blast_db = paste0(samples_dir, "/blast/blast_database/blast_database"),
        input = marker_genes_fasta,
        out = paste0(samples_dir, "/blast/blast_out"),
        format = 6)

  save.image(file = paste0(samples_dir, "/workspace_logs/",
                           Sys.time(), "_workspace.RData"))
  #####---------------------------------------------------------------------------------------------

  ##### Taxonomic assignment of whole samples and bins -----------------------------------------------------
  # CAT on contigs whole samples
  megahit_dirs = list.files(path = paste0(samples_dir, "/megahit"))
  contig_paths = paste0(samples_dir, "/megahit/", megahit_dirs, "/final.contigs.fa")

  for (i in seq(1, length(megahit_dirs))) {
    #get paths
    megahit_dir = megahit_dirs[i]
    contig_path = contig_paths[i]

    basename = str_replace(megahit_dir, pattern = "megahit_trimmed_", replacement = "")
    basename = str_split(basename, pattern = ".f")[[1]][1]

    run_CAT(samples_dir = samples_dir,
            outname = basename,
            contigpath = contig_path)
  }

  save.image(file = paste0(samples_dir, "/workspace_logs/",
                           Sys.time(), "_workspace.RData"))
  ##### -----------------------------------------------------------------------------------------------------

  ##### Creating krona plot of CAT taxonomies ------------------------------------
  CAT_files = list.files(path = paste0(samples_dir, "/CAT"))
  CAT_names = CAT_files[!CAT_files %in% "CAT_prepare_20190719"]
  CAT_files = paste0(samples_dir, "/CAT/", CAT_names, "/taxonomy.txt")

  CAT_infiles = list()
  for (i in 1:length(CAT_files)){
    CAT_file = CAT_files[i]
    CAT_name = CAT_names[i]
    sample_outfile = paste0(samples_dir, "/CAT/", CAT_name, "/", CAT_name, ".txt")
    CAT_infiles = append(CAT_infiles, sample_outfile)

    CAT_taxonomy_to_krona_format(CAT_file = CAT_file,
                                 outfile = sample_outfile)
  }
  CAT_infiles = unlist(CAT_infiles)
  ktImportText(input_files = CAT_infiles,
               outfile = paste0(samples_dir, "/CAT/krona_taxonomy.html"))
  ##### --------------------------------------------------------------------------


  ##### Running prokka annoations pipeline
  cmd = paste0("mkdir ", samples_dir, "/prokka")
  system(cmd)

  metabat_dir = paste0(samples_dir, "/metabat2")
  sample_dirs_metabat = paste0(metabat_dir, "/", list.files(metabat_dir))

  for (sample_dir in sample_dirs_metabat){
    files = list.files(sample_dir)
    contig = files[grepl(pattern = "total_", files)]
    basename = substr(contig, 7, nchar(contig)-3) #remove prefix and extention
    contig_path = paste0(sample_dir, "/", contig)

    #run prokka on renamed contigs per sample
    run_prokka(prokka_script = "inst/prokka.sh",
               contigpath = contig_path,
               outdir = paste0(samples_dir, "/prokka/", basename),
               prefix = basename)
  }

  save.image(file = paste0(samples_dir, "/workspace_logs/",
                           Sys.time(), "_workspace.RData"))

}

library("rjsonapi")
library("foreach")
library(parallel)
library(MASS)
library(ggplot2)
library(stringr)
library(sys)
library(dplyr)
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
source("/home/rstudio/scpackage/R/run_CAT.R")
source("/home/rstudio/scpackage/R/makeblastdb.R")
source("/home/rstudio/scpackage/R/blast.R")
source("/home/rstudio/scpackage/R/cat_rename_seq-id.R")
source("/home/rstudio/scpackage/R/CAT_taxonomy_to_krona_format.R")
source("/home/rstudio/scpackage/R/run_prokka.R")

run_sc_pipeline(samples_dir = "/home/rstudio/data/geodescent/test_samples",
                marker_genes_fasta = "/home/rstudio/scpackage/inst/extdata/M17.txt")

