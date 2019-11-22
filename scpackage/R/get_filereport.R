#' This function downloads the filereport of a study and saves it as an rda file in extdata. The intermediate file is deleted.
#'
#' @param url Url of the filereport. The url of a filereport of a study can be gotten from the corresponding ebi metagenomic website by saving the link address of the 'TEXT' button (e.g. see https://www.ebi.ac.uk/ena/data/view/PRJEB8968)
#' @param acc The study accession. This accession is also mentioned in the url (e.g. "PRJEB26733")
#'
#' @return The filereport as data frame. This is also stored as rda and can be loaded using load("extdata/filename")
#' @export
#'
#' @examples get_filereport(url = "https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=PRJEB8968&result=read_run&fields=study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,tax_id,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,sra_ftp,sra_galaxy,cram_index_ftp,cram_index_galaxy&download=txt",
#' acc = "PRJEB8968")
get_filereport = function(url, acc) {
  library(usethis)
  command = paste0("wget ", "'", url, "'")
  system(command)
  x = list.files(path = "./")
  for (filename in x){
    if (grepl(acc, filename) == TRUE){
      filepath = filename
    }
  }
  filereport = read.csv(filepath, sep = "\t")
  command = paste0("rm ", "'", filepath, "'")
  system(command)
  return(filereport)
}
