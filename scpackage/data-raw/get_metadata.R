#' This functions uses the MGnify API to connect to ebi to collect the metadata for the specifies MGYS accesion
#'
#' @param accession Mgnify accession of project, e.g. "MGYS00000991"
#'
#' @return Data frame of metadata as collected from ebi
#' @export
#'
#' @examples
#' get_metadata(accession = "MGYS00000991")
get_metadata = function(accession) {
  # load libraries, use install.packages(library) if not installed

  library("rjsonapi")
  library(plyr)

  # define project
  # create connection to the MGnify API
  conn <- jsonapi_connect("https://www.ebi.ac.uk", "metagenomics/api/v1")

  # Fetch samples
  samples <- conn$route(paste0("studies/", accession, "/samples", "?page_size=350"))

  # select columns and combine data into one DataFrame
  df = cbind(
    samples$data$attributes[,c("accession", "sample-name", "sample-desc")],
    biome=samples$data$relationships$biome$data$id
  )


  sample_metadata = samples$data$attributes$`sample-metadata`
  sample_ids <- samples$data$id
  for(i in 1:length(sample_metadata)){
    names(sample_metadata)[i] <- sample_ids[i]
  }

  fdf = data.frame()
  for (i in 1:length(sample_metadata)){
    id = sample_ids[i]
    data = sample_metadata[[i]]
    new_df = rbind(data$value)
    rownames(new_df) = id
    colnames(new_df) = data$key
    new_df = as.data.frame(new_df)
    fdf = rbind.fill(fdf,new_df)
  }
  rownames(fdf) = sample_ids

  df2 = cbind(fdf, df)

  names(df2)[names(df2) == "geographic location (longitude)"] <- "X"
  names(df2)[names(df2) == "geographic location (latitude)"] <- "Y"

  return(df2)
}

