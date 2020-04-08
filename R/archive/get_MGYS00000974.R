#' This functions uses the MGnify API to connect to ebi to collect the metadata for jcraig cruise MGYS00000974.
#'
#' @return Data frame samples and metadata 277 x 22
#' @export
#'
#' @examples
#' get_MGYS00000974()
get_MGYS00000974 = function() {
  # load libraries, use install.packages(library) if not installed
library("rjsonapi")

# define project
accession = "MGYS00000974"

# create connection to the MGnify API
conn <- jsonapi_connect("https://www.ebi.ac.uk", "metagenomics/api/v1")

# Fetch samples
samples <- conn$route(paste0("studies/", accession, "/samples", "?page_size=350"))
samples_2 <- conn$route(paste0("studies/", accession, "/samples", "?page=2","&page_size=350"))

# select columns and combine data into one DataFrame
df = cbind(
  samples$data$attributes[,c("accession", "sample-name", "sample-desc")],
  biome=samples$data$relationships$biome$data$id
)
df_2 = cbind(
  samples_2$data$attributes[,c("accession", "sample-name", "sample-desc")],
  biome=samples_2$data$relationships$biome$data$id
)

#adding data from the two pages together
df <- rbind(df, df_2)

sample_metadata = samples$data$attributes$`sample-metadata`
sample_metadata_2 = samples_2$data$attributes$`sample-metadata`


silicate <- list() #1
temperature <- list() #2
lat_lon <- list() #3
depth <- list() #4
region <- list() #5
collection_date <- list() #6  5
environment_biome <- list() #7  6
environment_feature <- list() #8  7
environmental_package <- list() #9  8
chlorophyll <- list() #10  9
dissolved_oxygen <- list() #11  10
nitrate <- list() #12  11
phosphate <- list() #13  12
salinity <- list() #14  13
NCBI_sample_classification <- list() #15  14
instrument_model <- list() #16  15
ENA_checklist <- list() #17  16

for(samplenumber in 1:250){
  if(length(sample_metadata[[samplenumber]]["value"]$value) == 17){
    silicate = append(silicate, sample_metadata[[samplenumber]]["value"]$value[1])
    temperature = append(temperature, sample_metadata[[samplenumber]]["value"]$value[2])
    lat_lon = append(lat_lon, sample_metadata[[samplenumber]]["value"]$value[3])
    depth = append(depth, sample_metadata[[samplenumber]]["value"]$value[4])
    region = append(region, sample_metadata[[samplenumber]]["value"]$value[5])
    collection_date = append(collection_date, sample_metadata[[samplenumber]]["value"]$value[6])
    environment_biome = append(environment_biome, sample_metadata[[samplenumber]]["value"]$value[7])
    environment_feature = append(environment_feature, sample_metadata[[samplenumber]]["value"]$value[8])
    environmental_package = append(environmental_package, sample_metadata[[samplenumber]]["value"]$value[9])
    chlorophyll = append(chlorophyll, sample_metadata[[samplenumber]]["value"]$value[10])
    dissolved_oxygen = append(dissolved_oxygen, sample_metadata[[samplenumber]]["value"]$value[11])
    nitrate = append(nitrate, sample_metadata[[samplenumber]]["value"]$value[12])
    phosphate = append(phosphate, sample_metadata[[samplenumber]]["value"]$value[13])
    salinity = append(salinity, sample_metadata[[samplenumber]]["value"]$value[14])
    NCBI_sample_classification = append(NCBI_sample_classification, sample_metadata[[samplenumber]]["value"]$value[15])
    instrument_model = append(instrument_model, sample_metadata[[samplenumber]]["value"]$value[16])
    ENA_checklist = append(ENA_checklist, sample_metadata[[samplenumber]]["value"]$value[17])
  }
  else{
    silicate = append(silicate, sample_metadata[[samplenumber]]["value"]$value[1])
    temperature = append(temperature, sample_metadata[[samplenumber]]["value"]$value[2])
    lat_lon = append(lat_lon, sample_metadata[[samplenumber]]["value"]$value[3])
    depth = append(depth, sample_metadata[[samplenumber]]["value"]$value[4])
    region = append(region, NA)
    collection_date = append(collection_date, sample_metadata[[samplenumber]]["value"]$value[5])
    environment_biome = append(environment_biome, sample_metadata[[samplenumber]]["value"]$value[6])
    environment_feature = append(environment_feature, sample_metadata[[samplenumber]]["value"]$value[7])
    environmental_package = append(environmental_package, sample_metadata[[samplenumber]]["value"]$value[8])
    chlorophyll = append(chlorophyll, sample_metadata[[samplenumber]]["value"]$value[9])
    dissolved_oxygen = append(dissolved_oxygen, sample_metadata[[samplenumber]]["value"]$value[10])
    nitrate = append(nitrate, sample_metadata[[samplenumber]]["value"]$value[11])
    phosphate = append(phosphate, sample_metadata[[samplenumber]]["value"]$value[12])
    salinity = append(salinity, sample_metadata[[samplenumber]]["value"]$value[13])
    NCBI_sample_classification = append(NCBI_sample_classification, sample_metadata[[samplenumber]]["value"]$value[14])
    instrument_model = append(instrument_model, sample_metadata[[samplenumber]]["value"]$value[15])
    ENA_checklist = append(ENA_checklist, sample_metadata[[samplenumber]]["value"]$value[16])
  }
}

for(samplenumber in 1:27){
  if(length(sample_metadata_2[[samplenumber]]["value"]$value) == 17){
    silicate = append(silicate, sample_metadata_2[[samplenumber]]["value"]$value[1])
    temperature = append(temperature, sample_metadata_2[[samplenumber]]["value"]$value[2])
    lat_lon = append(lat_lon, sample_metadata_2[[samplenumber]]["value"]$value[3])
    depth = append(depth, sample_metadata_2[[samplenumber]]["value"]$value[4])
    region = append(region, sample_metadata_2[[samplenumber]]["value"]$value[5])
    collection_date = append(collection_date, sample_metadata_2[[samplenumber]]["value"]$value[6])
    environment_biome = append(environment_biome, sample_metadata_2[[samplenumber]]["value"]$value[7])
    environment_feature = append(environment_feature, sample_metadata_2[[samplenumber]]["value"]$value[8])
    environmental_package = append(environmental_package, sample_metadata_2[[samplenumber]]["value"]$value[9])
    chlorophyll = append(chlorophyll, sample_metadata_2[[samplenumber]]["value"]$value[10])
    dissolved_oxygen = append(dissolved_oxygen, sample_metadata_2[[samplenumber]]["value"]$value[11])
    nitrate = append(nitrate, sample_metadata_2[[samplenumber]]["value"]$value[12])
    phosphate = append(phosphate, sample_metadata_2[[samplenumber]]["value"]$value[13])
    salinity = append(salinity, sample_metadata_2[[samplenumber]]["value"]$value[14])
    NCBI_sample_classification = append(NCBI_sample_classification, sample_metadata_2[[samplenumber]]["value"]$value[15])
    instrument_model = append(instrument_model, sample_metadata_2[[samplenumber]]["value"]$value[16])
    ENA_checklist = append(ENA_checklist, sample_metadata_2[[samplenumber]]["value"]$value[17])
  }
  else{
    silicate = append(silicate, sample_metadata_2[[samplenumber]]["value"]$value[1])
    temperature = append(temperature, sample_metadata_2[[samplenumber]]["value"]$value[2])
    lat_lon = append(lat_lon, sample_metadata_2[[samplenumber]]["value"]$value[3])
    depth = append(depth, sample_metadata_2[[samplenumber]]["value"]$value[4])
    region = append(region, NA)
    collection_date = append(collection_date, sample_metadata_2[[samplenumber]]["value"]$value[5])
    environment_biome = append(environment_biome, sample_metadata_2[[samplenumber]]["value"]$value[6])
    environment_feature = append(environment_feature, sample_metadata_2[[samplenumber]]["value"]$value[7])
    environmental_package = append(environmental_package, sample_metadata_2[[samplenumber]]["value"]$value[8])
    chlorophyll = append(chlorophyll, sample_metadata_2[[samplenumber]]["value"]$value[9])
    dissolved_oxygen = append(dissolved_oxygen, sample_metadata_2[[samplenumber]]["value"]$value[10])
    nitrate = append(nitrate, sample_metadata_2[[samplenumber]]["value"]$value[11])
    phosphate = append(phosphate, sample_metadata_2[[samplenumber]]["value"]$value[12])
    salinity = append(salinity, sample_metadata_2[[samplenumber]]["value"]$value[13])
    NCBI_sample_classification = append(NCBI_sample_classification, sample_metadata_2[[samplenumber]]["value"]$value[14])
    instrument_model = append(instrument_model, sample_metadata[[samplenumber]]["value"]$value[15])
    ENA_checklist = append(ENA_checklist, sample_metadata_2[[samplenumber]]["value"]$value[16])
  }
}


test <- unlist(lat_lon)
latitude = list()
longtitude = list()
for(samplenumber in 1:277){
  lat = strsplit(test[samplenumber], " ")[[1]][1]
  lon = strsplit(test[samplenumber], " ")[[1]][2]
  latitude = append(latitude, lat)
  longtitude = append(longtitude, lon)
}

#GDAL X = lon, Y = lat
df2 = data.frame("X" = unlist(longtitude))
df2$Y <- unlist(latitude)
df2$"silicate_umol/L" <- unlist(silicate)
df2$"temperature_&deg;C" <- unlist(temperature)
df2$depth_m <- unlist(depth)
df2$region <- unlist(region)
df2$collection_date <- unlist(collection_date)
df2$environment_biome <- unlist(environment_biome)
df2$environment_feature <- unlist(environment_feature)
df2$environmental_package <- unlist(environmental_package)
df2$"chlorophyll_mg/m3" <- unlist(chlorophyll)
df2$"dissolved_oxygen_mg/L" <- unlist(dissolved_oxygen)
df2$"nitrate_umol/L" <- unlist(nitrate)
df2$"phosphate_umol/L" <- unlist(phosphate)
df2$salinity_ppt <- unlist(salinity)
df2$NCBI_sample_classification <- unlist(NCBI_sample_classification)
df2$instrument_model <- unlist(instrument_model)
df2$ENA_checklist <- unlist(ENA_checklist)

df2 = cbind(df, df2)

MGYS00000974 <- df2

#save file
#write.csv(MGYS00000974, file = "extdata/MGYS00000974.csv")

return(MGYS00000974)
}

