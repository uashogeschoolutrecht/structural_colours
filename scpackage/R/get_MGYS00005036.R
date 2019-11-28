#' This functions uses the MGnify API to connect to ebi to collect the metadata for MGYS00005036
#'
#' @return Data frame metadata
#' @export
#'
#' @examples
#' get_MGYS00005036()
get_MGYS00005036 = function() {
  # load libraries, use install.packages(library) if not installed

  library("rjsonapi")

  # define project
  accession = "MGYS00005036"

  # create connection to the MGnify API
  conn <- jsonapi_connect("https://www.ebi.ac.uk", "metagenomics/api/v1")

  # Fetch samples
  samples <- conn$route(paste0("studies/", accession, "/samples", "?page_size=350"))

  # select columns and combine data into one DataFrame
  df = cbind(
    samples$data$attributes[,c("accession", "sample-name", "sample-desc")],
    biome=samples$data$relationships$biome$data$id
  )

  temperature = list()
  longitude = list()
  location = list()
  collection_date = list()
  environment_biome = list()
  environment_feature = list()
  environment_material = list()
  pH = list()
  latitude = list()
  instrument_model = list()
  last_update_date = list()




  sample_metadata = samples$data$attributes$`sample-metadata`
  for (sample_num in 1:length(sample_metadata)){
    keys = sample_metadata[[sample_num]]['value']
    temperature = append(temperature, keys[[1]][1])
    longitude = append(longitude, keys[[1]][2])
    location = append(location, keys[[1]][3])
    collection_date = append(collection_date, keys[[1]][4])
    environment_biome = append(environment_biome, keys[[1]][5])
    environment_feature = append(environment_feature, keys[[1]][6])
    environment_material = append(environment_material, keys[[1]][7])
    pH = append(pH, keys[[1]][8])
    latitude = append(latitude, keys[[1]][9])
    instrument_model = append(instrument_model, keys[[1]][10])
    last_update_date = append(last_update_date, keys[[1]][11])
  }

  #GDAL X = lon, Y = lat
  df2 = data.frame("X" = unlist(longitude))
  df2$Y <- unlist(latitude)
  df2$"temperature_&deg;C" <- unlist(temperature)
  df2$collection_date <- unlist(collection_date)
  df2$environment_biome <- unlist(environment_biome)
  df2$environment_feature <- unlist(environment_feature)
  df2$environment_material <- unlist(environment_material)
  df2$instrument_model <- unlist(instrument_model)
  df2$pH <- unlist(pH)
  df2$last_update_date <- unlist(last_update_date)
  df2$location <- unlist(location)

  df2 = cbind(df, df2)

  MGYS00005036 <- df2

  #save file
  #write.csv(MGYS00005036, file = "extdata/MGYS00005036.csv")

  return(MGYS00005036)
}
