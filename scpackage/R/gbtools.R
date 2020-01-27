#' Gbtools bin plot for Shiny
#'
#' @param covstats Path to bbmap covstat output file
#' @param taxonomy Path to CAT taxonomy output file
#' @param colour_tax_level Taxonomy level to colour contigs with, e.g. "Species", "Superkingdom". Default is "Genus".
#'
#' @return
#' @export
#'
#' @examples
#' gbtools_plot(covstats = "/home/rstudio/data/geodescent/test_samples/bbmap/bbmap_megahit_trimmed_control_IR1-reads.fastq/covstats.txt",
#' taxonomy = "/home/rstudio/data/geodescent/test_samples/CAT/control_IR1-reads/taxonomy.txt")
gbtools_plot = function(covstats_datapath, taxonomy_datapath, colour_tax_level = "Genus"){
  #install.packages('gbtools')
  #library(devtools)
  #install_github("kbseah/genome-bin-tools/gbtools")
  library(gbtools)

  # Loading in taxonomy marker table
  taxonomy_table = read.csv(taxonomy_datapath, sep = "\t")
  taxonomy_selected = subset(taxonomy_table, select=c("X..contig", "superkingdom", "phylum", "class",
                                                      "order", "family", "genus", "species")) %>%
    dplyr::rename(scaffold = X..contig) %>%
    dplyr::rename(Superkingdom = superkingdom) %>%
    dplyr::rename(Phylum = phylum) %>%
    dplyr::rename(Class = class) %>%
    dplyr::rename(Order = order) %>%
    dplyr::rename(Family = family) %>%
    dplyr::rename(Genus = genus) %>%
    dplyr::rename(Species = species)
  taxonomy_selected$markerid = NA
  taxonomy_selected$gene = NA

  taxonomy_selected$Superkingdom = gsub(pattern = "not classified", replacement = NA, taxonomy_selected$Superkingdom)
  taxonomy_selected$Phylum = gsub(pattern = "not classified", replacement = NA, taxonomy_selected$Phylum)
  taxonomy_selected$Class = gsub(pattern = "not classified", replacement = NA, taxonomy_selected$Class)
  taxonomy_selected$Order = gsub(pattern = "not classified", replacement = NA, taxonomy_selected$Order)
  taxonomy_selected$Family = gsub(pattern = "not classified", replacement = NA, taxonomy_selected$Family)
  taxonomy_selected$Genus = gsub(pattern = "not classified", replacement = NA, taxonomy_selected$Genus)
  taxonomy_selected$Species = gsub(pattern = "not classified", replacement = NA, taxonomy_selected$Species)


  # Getting the covstats file
  covstats_table = read.csv(covstats_datapath, sep = "\t")
  covstats_selected = subset(covstats_table, select=c("X.ID", "Avg_fold", "Length", "Ref_GC")) %>%
    filter(Length >= 1000) %>%
    dplyr::rename(ID = X.ID)
  covstats_selected$ID = as.character(covstats_selected$ID)
  IDs = unlist(strsplit(covstats_selected$ID, split = " "))[grepl(pattern = "k", unlist(strsplit(covstats_selected$ID, split = " ")))]
  covstats_selected$ID = IDs

  # Selecting taxonomies with contigs >= 1000
  taxonomy_selected = subset(taxonomy_selected, subset = taxonomy_selected$scaffold %in% covstats_selected$ID)

  # Writing and loading gbt object
  write.table(taxonomy_selected, file = 'taxonomy_filtered.txt', quote = FALSE, sep = "\t", row.names = FALSE)
  write.table(covstats_selected, file = 'covstats_filtered.txt', quote = FALSE, sep = "\t", row.names = FALSE)
  d <- gbt(covstats=c("covstats_filtered.txt"), mark = "taxonomy_filtered.txt", marksource = "user")
  system("rm taxonomy_filtered.txt")
  system("rm covstats_filtered.txt")

  # Creating plot of bins coloured by taxonomy
  bin_plot = plot(d, taxon = colour_tax_level)

  return(bin_plot)
}
