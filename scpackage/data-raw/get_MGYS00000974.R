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
df$X <- unlist(longtitude)
df$Y <- unlist(latitude)
df$silicate <- unlist(silicate)
df$temperature <- unlist(temperature)
df$depth <- unlist(depth)
df$region <- unlist(region)
df$collection_date <- unlist(collection_date)
df$environment_biome <- unlist(environment_biome)
df$environment_feature <- unlist(environment_feature)
df$environmental_package <- unlist(environmental_package)
df$chlorophyll <- unlist(chlorophyll)
df$dissolved_oxygen <- unlist(dissolved_oxygen)
df$nitrate <- unlist(nitrate)
df$phosphate <- unlist(phosphate)
df$salinity <- unlist(salinity)
df$NCBI_sample_classification <- unlist(NCBI_sample_classification)
df$instrument_model <- unlist(instrument_model)
df$ENA_checklist <- unlist(ENA_checklist)

MGYS00000974 <- df

# save to csv
#fname = paste0("~/API_testing/", accession, "_XY", ".csv")
#write.csv(df, file = fname)
readr::write_csv(MGYS00000974, path = "inst/extdata/MGYS00000974.csv")

usethis::use_data(MGYS00000974)
