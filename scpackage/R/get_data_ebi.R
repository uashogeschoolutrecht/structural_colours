#' This function downloads metadata and fastq files from ebi by MGnify accession
#'
#' @param accession MGnify accession, such as MGYS00000492
#' @param outdir Existing directory to store output files
#'
#' @return total_md5s The md5s of all the input samples
#' @export
#'
#' @examples
#' get_data_ebi(accession = "MGYS00000492",
#' outdir = "~/outdir")
get_data_ebi = function(accession, outdir){
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
  system("rm -rf ~/ncbi")
  ########################################################################


  ##### checksum #########################################################
  md5sum_results = read_delim(file = paste0(outdir, "/md5.txt"), delim = "\\t", col_names = FALSE)
  md5 = unlist(map(strsplit(md5sum_results$X2, " "),1))
  md5 = substr(md5, start = 2, stop = nchar(md5))
  md5_out = as.data.frame(cbind(md5sum_results$X1, md5))
  md5_in = as.data.frame(cbind(as.character(metadata$run_accession), as.character(metadata$sra_md5)))
  md5_out = dplyr::rename(md5_out, out_md5 = md5)
  md5_in = dplyr::rename(md5_in, in_md5 = V2)
  md5s = join(md5_in, md5_out)

  all_md5s = md5s

  failed_accessions = list()
  for (i in 1:length(as.character(md5s$V1))){
    print(i)
    in_md5 = as.character(md5s$in_md5)[i]
    out_md5 = as.character(md5s$out_md5)[i]
    if (in_md5 != out_md5){
      failed_accession = as.character(md5s$V1)[i]
      print(paste0("md5 of downloaded sample ", failed_accession, ": ", out_md5,
                   " does not match the md5: ", in_md5, "."))
      failed_accessions = append(failed_accessions, failed_accession)
    }
  }

  if (length(failed_accessions) != 0){
    print("Samples with incorrent md5 detected. Will retry downloading failed samples.")
    counter_max = 3
    counter = 0
    repeat {
      counter = counter + 1
      print(paste0("Retrying download, try #", counter))
      system(paste0("rm ", outdir, "/md5.txt"))
      for (i in 1:length(failed_accessions)){
        acc = failed_accessions[i]
        record = subset(metadata, metadata$run_accession == acc)
        if (as.character(record$library_layout) == "PAIRED"){
          lib = "-split-files"
        } else {
          lib = ""
        }
        system(paste0("bash /home/rstudio/scpackage/inst/get_data_ebi.sh -a ", acc, " -o ", outdir, " -l ", lib))
        system(paste0("mv ", acc, "* ", outdir))
      }
      system("rm -rf ~/ncbi")
      #recheck md5
      md5sum_results = read_delim(file = paste0(outdir, "/md5.txt"), delim = "\\t", col_names = FALSE)
      md5 = unlist(map(strsplit(md5sum_results$X2, " "),1))
      md5 = substr(md5, start = 2, stop = nchar(md5))
      md5_out = as.data.frame(cbind(md5sum_results$X1, md5))
      md5_in = as.data.frame(cbind(as.character(metadata$run_accession), as.character(metadata$sra_md5)))
      md5_out = rename(md5_out, out_md5 = md5)
      md5_in = rename(md5_in, in_md5 = V2)
      md5s = join(md5_in, md5_out)
      system(paste0("rm ", outdir, "/md5.txt"))
      failed_accessions = list()
      for (i in 1:length(md5s$V1)){
        in_md5 = as.character(md5s$in_md5)[i]
        out_md5 = as.character(md5s$out_md5)[i]
        if (in_md5 != out_md5){
          failed_accession = as.character(md5s$V1)[i]
          print(paste0("md5 of downloaded sample ", failed_accession, ": ", out_md5,
                       " does not match the md5: ", in_md5, "."))
          failed_accessions = append(failed_accessions, failed_accession)
        }
      }
      if (counter == counter_max | length(failed_accessions) == 0){
        print("Either the max tries have been tried or there are no more failed downloads left.")
        print(paste0("Failed downloads left: ", as.character(failed_accessions)))
        break
      }
    }
  }
  return(all_md5s)
}
