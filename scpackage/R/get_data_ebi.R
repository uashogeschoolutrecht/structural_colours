#' This function downloads metadata and fastq files from ebi by MGnify accession
#'
#' @param accession MGnify accession, such as MGYS00000492
#' @param outdir Existing directory to store output files
#' @param ncbi_dir Directory where ncbi sra files are stored, edit temp dir path in ~/.ncbi/user-settings.mkfg
#'
#' @return total_md5s The md5s of all the input samples
#' @export
#'
#' @examples
#' get_data_ebi(accession = "MGYS00000492",
#' outdir = "~/outdir")
get_data_ebi = function(accession, outdir, ncbi_dir){
  library("httr")
  require("httr")
  library("jsonlite")
  require("jsonlite")
  library("rjsonapi")
  library(plyr)
  library(dplyr)
  library(purrr)
  library(readr)
  library(stringr)

  ##### MGnify rest api ################################################
  base <- "https://www.ebi.ac.uk/metagenomics/api/v1/"
  endpoint <- "studies"

  call <- paste0(base, endpoint,"?","accession","=", accession)
  get_info <- GET(call)

  get_text <- content(get_info, "text")
  get_json <- fromJSON(get_text)
  get_df <- as.data.frame(get_json$data)

  ena_accession <- get_df$attributes$bioproject
  ebi_accession <- accession
  ######################################################################


  ##### get filreport ena ##############################################
  url <- paste0("https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=", ena_accession,
                "&result=read_run&fields=study_accession,sample_accession,sra_md5,secondary_sample_accession,experiment_accession,run_accession,tax_id,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,sra_ftp,sra_galaxy,cram_index_ftp,cram_index_galaxy&download=txt")

  command <- paste0("wget ", "'", url, "'")
  system(command)
  x <- list.files(path = "./")
  for (filename in x){
    if (grepl(ena_accession, filename) == TRUE){
      filepath = filename
    }
  }
  filereport <- read.csv(filepath, sep = "\t")
  command <- paste0("rm ", "'", filepath, "'")
  system(command)

  if (nrow(filereport) == 0) {
    ena_accession_thirdp <- str_extract(get_df$attributes$`study-abstract`, pattern = "(?<=\\b)PRJ[^\\s]+")
    ena_accession_thirdp <- substr(ena_accession_thirdp, 1, nchar(ena_accession_thirdp) - 1)
    print(paste0("No metadata found for ", ena_accession, ". Trying ", ena_accession_thirdp))

    url <- paste0("https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=", ena_accession_thirdp, "&result=read_run&fields=study_accession,sample_accession,sra_md5,secondary_sample_accession,experiment_accession,run_accession,tax_id,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,sra_ftp,sra_galaxy,cram_index_ftp,cram_index_galaxy&download=txt")

    command <- paste0("wget ", "'", url, "'")
    system(command)
    x <- list.files(path = "./")
    for (filename in x) {
      if (grepl(ena_accession_thirdp, filename) == TRUE) {
        filepath = filename
      }
    }
    filereport <- read.csv(filepath, sep = "\t")
    command <- paste0("rm ", "'", filepath, "'")
    system(command)
  }
  ######################################################################


  ##### get metadatat ##################################################
  # define project
  # create connection to the MGnify API
  conn <- jsonapi_connect("https://www.ebi.ac.uk", "metagenomics/api/v1")

  # Fetch samples
  samples <- conn$route(paste0("studies/", ebi_accession, "/samples", "?page_size=350"))

  # select columns and combine data into one DataFrame
  df <- cbind(
    samples$data$attributes[,c("accession", "sample-name", "sample-desc")],
    biome=samples$data$relationships$biome$data$id
  )


  sample_metadata <- samples$data$attributes$`sample-metadata`
  sample_ids <- samples$data$id
  for(i in 1:length(sample_metadata)){
    names(sample_metadata)[i] <- sample_ids[i]
  }

  fdf <- data.frame()
  for (i in 1:length(sample_metadata)){
    id = sample_ids[i]
    data = sample_metadata[[i]]
    new_df = rbind(data$value)
    rownames(new_df) = id
    colnames(new_df) = data$key
    new_df = as.data.frame(new_df)
    fdf = rbind.fill(fdf,new_df)
  }
  rownames(fdf) <- sample_ids

  df2 <- cbind(fdf, df)

  names(df2)[names(df2) == "geographic location (longitude)"] <- "X"
  names(df2)[names(df2) == "geographic location (latitude)"] <- "Y"
  ########################################################################


  ##### combine metdatata ################################################
  samples_report_with_metadata <- filereport %>%
    dplyr::filter(secondary_sample_accession %in% df2$accession) %>%
    dplyr::rename(accession = secondary_sample_accession)

  metadata <- dplyr::inner_join(x = samples_report_with_metadata, y = df2, by = c("accession"))
  write.csv(metadata, file = paste0(outdir, "/", accession, "_metadata.txt"), quote = FALSE)
  ########################################################################

  ##### get sra downloads ################################################
  for (i in 1:length(metadata$run_accession)){
    if (as.character(metadata$library_layout)[i] == "PAIRED"){
      lib = "-split-files"
    } else {
      lib = ""
    }
    acc = as.character(metadata$run_accession)[i]
    system(paste0("bash /home/rstudio/scpackage/inst/get_data_ebi.sh -a ", acc, " -o ", outdir, " -l ", lib))
    system(paste0("mv ", acc, "* ", outdir))
  }
  system(paste0("rm -rf ", ncbi_dir))
  ########################################################################

}
