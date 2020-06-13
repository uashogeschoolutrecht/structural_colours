library(sparklyr)
library(dplyr)
spark_install(version = "2.0")
sc <- spark_connect(master = "local")



#subsetting metadata
accessions = c("ERR164408","ERR1701760","ERR315859","ERR315861",
               "ERR164407","ERR164409","ERR315858","ERR315860","ERR315862")
metadata = MGYS00000410_metadata[MGYS00000410_metadata$run_accession %in% accessions,]
metadata_sc = copy_to(sc, metadata)



#adding CAT results to the spark database
ERR164407_blast = read.csv(file = "/data/tara_output/blast/ERR164407/blast_out", sep = "\t", header = FALSE)
ERR164407_blast$run_accession = 1
ERR164408_blast = read.csv(file = "/data/tara_output/blast/ERR164408/blast_out", sep = "\t", header = FALSE)
ERR164408_blast$run_accession = 2
ERR164409_blast = read.csv(file = "/data/tara_output/blast/ERR164409/blast_out", sep = "\t", header = FALSE)
ERR164409_blast$run_accession = 3
ERR1701760_blast = read.csv(file = "/data/tara_output/blast/ERR1701760/blast_out", sep = "\t", header = FALSE)
ERR1701760_blast$run_accession = 4
ERR315858_blast = read.csv(file = "/data/tara_output/blast/ERR315858/blast_out", sep = "\t", header = FALSE)
ERR315858_blast$run_accession = 5
ERR315859_blast = read.csv(file = "/data/tara_output/blast/ERR315859/blast_out", sep = "\t", header = FALSE)
ERR315859_blast$run_accession = 6
ERR315860_blast = read.csv(file = "/data/tara_output/blast/ERR315860/blast_out", sep = "\t", header = FALSE)
ERR315860_blast$run_accession = 7
ERR315861_blast = read.csv(file = "/data/tara_output/blast/ERR315861/blast_out", sep = "\t", header = FALSE)
ERR315861_blast$run_accession = 8
ERR315862_blast = read.csv(file = "/data/tara_output/blast/ERR315862/blast_out", sep = "\t", header = FALSE)
ERR315862_blast$run_accession = 9
blast = bind_rows(ERR164407_blast, ERR164408_blast, ERR164409_blast, ERR315858_blast,
                  ERR315859_blast, ERR1701760_blast,
                  ERR315860_blast, ERR315861_blast, ERR315862_blast)
colnames(blast) = c("query", "reference", "identity", "length", "mismatch", "gapopen",
                    "qstart", "qend", "sstart", "send", "evalue", "bitscore", "run_accession")

blast_sc = copy_to(sc, blast, overwrite = T)



#adding CAT taxonomy results to spark database
ERR164407_CAT = read.csv(file = "/data/tara_output/CAT/ERR164407/taxonomy.txt", sep = "\t", header = TRUE)
ERR164407_CAT$run_accession = "ERR164407"
ERR164407_CAT_sc = copy_to(sc, ERR164407_CAT)

ERR164408_CAT = read.csv(file = "/data/tara_output/CAT/ERR164408/taxonomy.txt", sep = "\t", header = TRUE)
ERR164408_CAT$run_accession = "ERR164408"
ERR164408_CAT_sc = copy_to(sc, ERR164408_CAT)

ERR164409_CAT = read.csv(file = "/data/tara_output/CAT/ERR164409/taxonomy.txt", sep = "\t", header = TRUE)
ERR164409_CAT$run_accession = "ERR164409"
ERR164409_CAT_sc = copy_to(sc, ERR164409_CAT)

ERR1701760_CAT = read.csv(file = "/data/tara_output/CAT/ERR1701760/taxonomy.txt", sep = "\t", header = TRUE)
ERR1701760_CAT$run_accession = "ERR1701760"
ERR1701760_CAT_1 = ERR1701760_CAT[1:600000,]
ERR1701760_CAT_2 = ERR1701760_CAT[600001:1302040,]

ERR1701760_CAT_1_sc = copy_to(sc, ERR1701760_CAT_1)

ERR315858_CAT = read.csv(file = "/data/tara_output/CAT/ERR315858/taxonomy.txt", sep = "\t", header = TRUE)
ERR315858_CAT$run_accession = "ERR315858"
ERR315859_CAT = read.csv(file = "/data/tara_output/CAT/ERR315859/taxonomy.txt", sep = "\t", header = TRUE)
ERR315859_CAT$run_accession = "ERR315859"
ERR315860_CAT = read.csv(file = "/data/tara_output/CAT/ERR315860/taxonomy.txt", sep = "\t", header = TRUE)
ERR315860_CAT$run_accession = "ERR315860"
ERR315861_CAT = read.csv(file = "/data/tara_output/CAT/ERR315861/taxonomy.txt", sep = "\t", header = TRUE)
ERR315861_CAT$run_accession = "ERR315861"
ERR315862_CAT = read.csv(file = "/data/tara_output/CAT/ERR315862/taxonomy.txt", sep = "\t", header = TRUE)
ERR315862_CAT$run_accession = "ERR315862"
CAT = bind_rows(ERR164407_CAT, ERR164408_CAT, ERR164409_CAT, ERR1701760_CAT, ERR315858_CAT,
                  ERR315859_CAT, ERR315860_CAT, ERR315861_CAT, ERR315862_CAT)

metadata_tbl <- sdf_copy_to(sc, metadata, name = "metadata_tbl", overwrite = TRUE)
data(iris)
pca = ml_pca(metadata_tbl)

sc <- spark_connect(master = "local")
iris_tbl <- sdf_copy_to(sc, iris, name = "iris_tbl", overwrite = TRUE)

iris_tbl %>%
  select(-Species) %>%
  ml_pca(k = 2)



pca <- blast_sc %>%
  select(-reference) %>%
  select(-query) %>%
  ml_pca(k=2)


my_theme <- function(base_size = 12, base_family = "sans"){
  theme_minimal(base_size = base_size, base_family = base_family) +
    theme(
      axis.text = element_text(size = 12),
      axis.title = element_text(size = 14),
      panel.grid.major = element_line(color = "grey"),
      panel.grid.minor = element_blank(),
      panel.background = element_rect(fill = "aliceblue"),
      strip.background = element_rect(fill = "lightgrey", color = "grey", size = 1),
      strip.text = element_text(face = "bold", size = 12, color = "black"),
      legend.position = "right",
      legend.justification = "top",
      panel.border = element_rect(color = "grey", fill = NA, size = 0.5)
    )
}
install.packages('ggrepel')
library(ggrepel)
library(ggplot2)
library(tibble)
rownames(pca)
as.data.frame(pca$pc) %>%
  rownames_to_column(var = "labels") %>%
  ggplot(aes(x = PC1, y = PC2, color = labels, label = labels)) +
  geom_point(size = 3, alpha = 0.5) +
  geom_text_repel() +
  labs(x = paste0("PC1: ", round(pca$explained_variance[1], digits = 2) * 100, "% variance"),
       y = paste0("PC2: ", round(pca$explained_variance[2], digits = 2) * 100, "% variance")) +
  ggtitle("PCA plot of BLASTp results of structural colour markers against the first nine Tara samples.") +
  guides(fill = FALSE, color = FALSE)

