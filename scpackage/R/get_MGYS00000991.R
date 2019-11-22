#' This functions uses the MGnify API to connect to ebi to collect the metadata for jcraig cruise MGYS00000974.
#'
#' @return Data frame samples and metadata 277 x 22
#' @export
#'
#' @examples
#' get_MGYS00000974()
#'
#'
#'
get_MGYS00000991 = function() {
  # load libraries, use install.packages(library) if not installed

  library("rjsonapi")
  library(plyr)

  # define project
  accession = "MGYS00000991"
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


fdf$temperature[which(fdf$temperature == "-999.0")] <- NA


  df2 = cbind(fdf, df)

  MGYS00000991 <- df2

  names(MGYS00000991)[names(MGYS00000991) == "geographic location (longitude)"] <- "X"
  names(MGYS00000991)[names(MGYS00000991) == "geographic location (latitude)"] <- "Y"


x = df2[which(is.na(df2$`geographic location (longitude)`)),]
y = subset(df2, !`geographic location (longitude)` %in% x$`geographic location (longitude)`)

names(y)[names(y) == "geographic location (longitude)"] <- "X"
names(y)[names(y) == "geographic location (latitude)"] <- "Y"

MGYS00000991 = y
names(MGYS00000991)[names(MGYS00000991) == "temperature"] <- "temperature_&deg;C"
names(MGYS00000991)[names(MGYS00000991) == "depth"] <- "depth_m"
  return(MGYS00000991)
}

