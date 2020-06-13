#' Shotgun metagenomic analysis and marker gene detection pipeline.
#'
#' @param samples_dir Path to directory with fastq files of input samples
#' @param marker_genes_fasta Path to fasta file of input marker protein(s).
#'
#' @return
#' @export
#'
#' @examples
run_sc_pipeline = function(sample_path, outdir, marker_genes_fasta) {
  #### Getting sample name -------------------------------------------------------------------
  if (length(sample_path) == 2){
    sample_filename1 = last(strsplit(sample_path[1], "/")[[1]])
    sample_accession = str_split(sample_filename1, pattern = "_[0123456789].f")[[1]][1]
  } else {
    sample_filename = last(strsplit(sample_path, "/")[[1]])
    sample_accession = strsplit(sample_filename, ".f")[[1]][1]
  }


  #### Creating output directory -------------------------------------------------------------
  if (file.exists(outdir)){
    print(paste0("Output directory ", outdir, " detected."))
  } else {
    print(paste0("Creating output directory: ", outdir))
    system(paste0("mkdir ", outdir))
  }


  ##### FastQC quality control ---------------------------------------------------------------
  command = paste0("mkdir -p ", outdir, "/fastqc/untrimmed/", sample_accession)
  system(command)

  for (sample in sample_path){
    run_fastqc(sample, outdir = paste0(outdir, "/fastqc/untrimmed/", sample_accession))
  }


  ##### Quality trimming ---------------------------------------------------------------------
  #creating output folder
  command = paste0("mkdir -p ", outdir, "/trimmed/", sample_accession)
  system(command)
  if (length(sample_path) == 2){
    trim_stat = run_trimmomatic(mode = "PE",
                                f1 = sample_path[1],
                                f2 = sample_path[2],
                                prefix = paste0("trimmed_", sample_accession))
  } else {
    trim_stat = run_trimmomatic(mode = "SE",
                                f1 = sample_path,
                                prefix = paste0("trimmed_", sample_accession))
  }
  command = paste0("mv ", "trimmed_* ", outdir, "/trimmed/", sample_accession)
  system(command)
  #log
  system(paste0("mkdir ", outdir, "/workspace_logs"))
  save.image(file = paste0(outdir, "/workspace_logs/",
                           Sys.time(), "_workspace.RData"))


  ##### FastQC quality control 2: after trimming ---------------------------------------------
  command = paste0("mkdir -p ", outdir, "/fastqc/trimmed/", sample_accession)
  system(command)
  trimmed_sample = paste0(outdir, "/trimmed/", sample_accession, "/", list.files(path = paste0(outdir, "/trimmed/", sample_accession)))
  subset_unorphaned = str_detect(trimmed_sample, pattern = "_[0123456789]P")
  if (subset_unorphaned != FALSE){
    trimmed_sample = trimmed_sample[subset_unorphaned]
  }


  for (sample in trimmed_sample){
    run_fastqc(sample, outdir = paste0(outdir, "/fastqc/trimmed/", sample_accession))
  }


  ##### Assembly -------------------------------------------------------------------------
  # to create longer seqs for less fragmented genes / better taxonomic assignment
  # creating output path
  megahit_outdir = paste0(outdir, "/megahit")
  header = c("megahit_outname", "read_1", "read_2")
  if (length(trimmed_sample) == 2) {
    run_megahit(
      PE = T,
      script_path = "/structural_colours/inst/megahit.sh",
      r1 = trimmed_sample[1],
      r2 = trimmed_sample[2],
      outdir = megahit_outdir,
      outname = sample_accession
    )
    io_log = c(sample_accession, trimmed_sample[1], trimmed_sample[2])
  } else {
    run_megahit(
      PE = F,
      script_path = "/structural_colours/inst/megahit.sh",
      r1 = trimmed_sample,
      outdir = megahit_outdir,
      outname = sample_accession
    )
    io_log = c(sample_accession, trimmed_sample, "NA")
  }
  megahit_io = rbind(header, io_log)
  save.image(file = paste0(outdir, "/workspace_logs/",
                           Sys.time(), "_workspace.RData"))


  ##### Assembly quality assessment -----------------------------------------------------
  # using quast the assemblies stats can be calulated, using bbmap the coverage of each contig.
  # getting path to contigs
  contig_path = paste0(outdir, "/megahit/", sample_accession, "/final.contigs.fa")

  # creating quast output directory
  command = paste0("mkdir ", outdir, "/quast")
  system(command)

  # running quast
  run_quast(filepath = contig_path,
            outdir = paste0(outdir, "/quast/", sample_accession))

  # collecting basic stats assemblies
  quast_parent_dir = paste0(outdir, "/quast")
  quast_summary_stats = quast_summary(quast_parent_dir = quast_parent_dir)

  write.csv(quast_summary_stats, file = paste0(outdir, "/quast/", accession, "/quast_sum_stats.txt"), quote = FALSE)

  #x = read.csv(file = "/data/tara_output/metabat2/ERR164407/bin_log.txt")

  #create bbmap main outdir
  command = paste0("mkdir ", outdir, "/bbmap")
  system(command)

  # running bbmap
  if (length(trimmed_sample) == 2){
    bbmap_log = run_bbmap(mode = "PE",
                    read1 = trimmed_sample[1],
                    read2 = trimmed_sample[2],
                    ref = paste0(outdir, "/megahit/", sample_accession, "/final.contigs.fa"),
                    outdir = paste0(outdir, "/bbmap/", sample_accession)
    )
  } else {
    bbmap_log = run_bbmap(mode = "SE",
                    read1 = trimmed_sample[1],
                    ref = paste0(outdir, "/megahit/", sample_accession, "/final.contigs.fa"),
                    outdir = paste0(outdir, "/bbmap/", sample_accession)
    )
  }

    for (line in bbmap_log) {
      if (grepl("Reads:", line) == TRUE) {
        start_results = match(line, bbmap_log)
      }
      if (grepl("Percent of reference bases covered:", line) == TRUE) {
        end_results = match(line, bbmap_log)
      }
    }
    results = bbmap_log[start_results:end_results]
    bbmap_header = c("Reference:", sample_accession)
    for (line in results) {
      line = strsplit(line, split = '\t')
      bbmap_header = rbind(bbmap_header, unlist(line))
      record = t(bbmap_header)
      colnames(record) = NULL
      rownames(record) = NULL
    }

  bbmap_summary_stats = record


  write.csv(bbmap_summary_stats, file = paste0(outdir, "/bbmap/", accession, "/sum_stats.txt"), quote = FALSE)



  ##### Binning ------------------------------------------------------------------------
  # to be able to get an idea from which taxonomic group a hit on a contig is, the contigs will be binned.
  # bbmap output is used to make the tool more sensitive
  binlog_header = c("Input:", "Bins:", "Percentage binned:")
  command = paste0("mkdir ", outdir, "/metabat2")
  system(command)
  sorted_bam_path = paste0(outdir, "/bbmap/", sample_accession, "/mapped_sorted.bam")
  #run metbata
  metabat_log = run_metabat2(metabat_script = "/structural_colours/inst/metabat2.sh",
                             s_bam = sorted_bam_path,
                             fasta = contig_path
  )
  # create output folder
  command = paste0("mkdir ", outdir, "/metabat2/", sample_accession)
  system(command)
  # move output files
  command = paste0("mv mapped.* ", outdir, "/metabat2/", sample_accession)
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
  new_log_record = c(sample_accession, bin, perc)
  binlog_header = rbind(binlog_header, new_log_record)
  metabat2_log = binlog_header



  write.csv(metabat2_log, file = paste0(outdir, "/metabat2/", accession, "/bin_log.txt"), quote = FALSE)


  ##### Blast  -------------------------------------------------------------------------------
  cmd = paste0("mkdir -p ", outdir, "/blast/", sample_accession)
  system(cmd)

  #renaming adding bin and sample names to contigs to retrace
  metabat_dir = paste0(outdir, "/metabat2")
  cat_rename_seq_id(outdir = outdir,
                    sample_accession = sample_accession)
  blast_db_fasta = paste0(outdir, "/blast/", sample_accession, "/database.fa")
  #concatenating renamed contig files for use in make blast db
  files = list.files(paste0(outdir, "/metabat2/", sample_accession))
  contig_file = files[grepl("total_", files)]
  contig_path = paste0(outdir, "/metabat2/", sample_accession, "/", contig_file)
  if (file.exists(blast_db_fasta) == FALSE){
    command = paste0("cat ", contig_path, " >> ", blast_db_fasta)
    system(command)
  }

  #making blast db
  makeblastdb(input = blast_db_fasta,
              outname = 'blast_database',
              outdir = paste0(outdir, "/blast/", sample_accession, "/"),
              dbtype = 'nucl')

  #running tblastn (prot against nucl)
  blast(blast = "tblastn",
        blast_db = paste0(outdir, "/blast/", sample_accession, "/blast_database/blast_database"),
        input = marker_genes_fasta,
        out = paste0(outdir, "/blast/", sample_accession, "/blast_out"),
        format = 6)

  save.image(file = paste0(outdir, "/workspace_logs/",
                           Sys.time(), "_workspace.RData"))


  ##### Taxonomic assignment of whole samples and bins -----------------------------------------------------
  # CAT on contigs whole samples
  run_CAT(samples_dir = outdir,
          outname = sample_accession,
          contigpath = contig_path)

  save.image(file = paste0(outdir, "/workspace_logs/",
                           Sys.time(), "_workspace.RData"))


  ##### Creating krona plot of CAT taxonomies ------------------------------------
  CAT_file = paste0(outdir, "/CAT/", sample_accession, "/taxonomy.txt")
  sample_outfile = paste0(outdir, "/CAT/", sample_accession, "/", sample_accession, ".txt")
  CAT_taxonomy_to_krona_format(CAT_file = CAT_file,
                               outfile = sample_outfile)
  ktImportText(input_files = sample_outfile,
               outfile = paste0(outdir, "/CAT/", sample_accession, "/krona_taxonomy.html"))


  # ##### Running prokka annoations pipeline
  cmd = paste0("mkdir ", outdir, "/prokka")
  system(cmd)

  contig_path = paste0(outdir, "/metabat2/", sample_accession, "/total_", sample_accession, ".fa")

  print(
    "Running prokka annotation pipeline.
  In case of error make sure the sample-specific output directory does not already exist.
  If there is an error but output is still generated the tbl2asn program may be outdated.
  If this is the case one (non-essential) output file will be missing."
  )

  try(
    run_prokka(prokka_script = "/structural_colours/inst/prokka.sh",
               contigpath = contig_path,
               outdir = paste0(outdir, "/prokka/", sample_accession),
               prefix = sample_accession)
  )

  save.image(file = paste0(outdir, "/workspace_logs/",
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
source("/structural_colours/R/get_filereport.R")
source("/structural_colours/R/get_metadata.R")
source("/structural_colours/R/get_fastq.R")
source("/structural_colours/R/grinder.R")
source("/structural_colours/R/run_fastqc.R")
source("/structural_colours/R/fastqc_multisummary.R")
source("/structural_colours/R/run_trimmomatic.R")
source("/structural_colours/R/run_megahit.R")
source("/structural_colours/R/run_quast.R")
source("/structural_colours/R/quast_summary.R")
source("/structural_colours/R/run_bbmap.R")
source("/structural_colours/R/run_metabat2.R")
source("/structural_colours/R/run_CAT.R")
source("/structural_colours/R/makeblastdb.R")
source("/structural_colours/R/blast.R")
source("/structural_colours/R/cat_rename_seq-id.R")
source("/structural_colours/R/CAT_taxonomy_to_krona_format.R")
source("/structural_colours/R/ktImportText.R")
source("/structural_colours/R/run_prokka.R")


for (file in list.files(path = "/data2")[6:17]){
  outdir = "/data/tara_output"
  accession = str_split(string = file, pattern = "_")[[1]][1]
  if (any(grepl(pattern = accession, list.files(path = paste0(outdir, "/prokka")))) == FALSE){
  if (grepl(pattern = ".gz", file)){
    #only files with .gz, zipped fastq files.
    if (grepl(pattern = "_2.f", file)){
      #sample is PE
      accession = str_split(string = file, pattern = "_2.f")[[1]][1]
      sample_path = c(paste0("/data2/", accession, "_1.fastq.gz"),
                      paste0("/data2/", accession, "_2.fastq.gz"))

        run_sc_pipeline(sample_path = sample_path,
                        marker_genes_fasta = "/structural_colours/inst/extdata/sc_markers.faa",
                        outdir = "/data/tara_output")
        cat(sample_path, sep = ",", file = "/data/tara_pipeline_batch1", append = TRUE)


    } else {
      if (grepl(pattern = "_1.f", file) == FALSE){
        #SE samples
        sample_path = paste0("/data2/", file)
        run_sc_pipeline(sample_path = sample_path,
                        marker_genes_fasta = "/structural_colours/inst/extdata/sc_markers.faa",
                        outdir = "/data/tara_output")
        cat(sample_path, sep = ",", file = "/data/tara_pipeline_batch1", append = TRUE)
      }
    }
  }}
}

# run_sc_pipeline(sample_path = sample_path,
#                 marker_genes_fasta = "/structural_colours/inst/extdata/sc_markers.faa",
#                 outdir = "/data/tara_output")

