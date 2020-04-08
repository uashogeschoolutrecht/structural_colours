library("rvest")
library(tidyverse)
library(plyr)
cog = "ftp://ftp.ncbi.nih.gov/pub/wolf/COGs/COG0303/cogs.csv"
url = "https://ecoliwiki.org/colipedia/index.php/Clusters_of_Orthologous_Groups_%28COGs%29"
xpath = '//*[@id="mw-content-text"]/div/table[2]'
prokka = "/home/rstudio/prokka_test/S1.tsv"
prokka2 = "/home/rstudio/prokka_test2/S1.tsv"

table = xml2::read_html(url) %>%
  html_nodes(xpath = xpath) %>%
  html_table()
table = table[[1]]

command = paste("wget",cog)
system(command)
command2 = paste("mv /home/rstudio/cogs.csv", "/home/rstudio/scpackage/inst/extdata")

c2 = read_fwf("/home/rstudio/scpackage/inst/extdata/cogs.csv", fwf_widths(c(7, 2, NA), c("cog", "n", "description")))

rex <- "^,"

c2 <- c2 %>%
  mutate(
  n_new = str_replace_all(
    pattern = rex,
    string = n,
    replacement = ""),
  n_new = trimws(n_new)
    )

c2 <- c2 %>%
  mutate(
    description_new = str_replace_all(
      pattern = rex,
      string = description,
      replacement = ""),
    description_new = trimws(description_new)
  )

prokka_file = read_tsv(prokka)
prokka2_file = read_tsv(prokka2)

prokka_cogs = na.omit(prokka_file$COG)
prokka_2cogs = na.omit(prokka2_file$COG)

ns = list()
for (cog in prokka_cogs){
  row_n = unlist(which(c2 == cog, arr.ind=TRUE))[1]
  n = c2[row_n, 4]
  ns = append(ns, n)
}
ns = unlist(ns)

ns2 = list()
for (cog in prokka_2cogs){
  row_n = unlist(which(c2 == cog, arr.ind=TRUE))[1]
  n = c2[row_n, 4]
  ns2 = append(ns2, n)
}
ns2 = unlist(ns2)

t_ns = table(ns)
t_ns2 = table(ns2)
sum(t_ns)

dataset = matrix(c(t_ns["N"], t_ns2["N"], sum(t_ns)-t_ns["N"], sum(t_ns2)-t_ns2["N"]), 2, 2)


fisher.test(dataset)
