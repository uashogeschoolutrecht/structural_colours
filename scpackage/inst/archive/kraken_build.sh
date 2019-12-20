kraken2-build --download-taxonomy --db /home/rstudio/data/kraken_db

#standard db
kraken2-build --download-library archaea --db /home/rstudio/data/kraken_db
kraken2-build --download-library bacteria --db /home/rstudio/data/kraken_db
kraken2-build --download-library viral --db /home/rstudio/data/kraken_db
kraken2-build --download-library human --db /home/rstudio/data/kraken_db
kraken2-build --download-library UniVec_Core --db /home/rstudio/data/kraken_db

kraken2-build --download-library plant --db /home/rstudio/data/kraken_db
kraken2-build --download-library protozoa --db /home/rstudio/data/kraken_db
kraken2-build --download-library fungi --db /home/rstudio/data/kraken_db
kraken2-build --build --db /home/rstudio/data/kraken_db --threads 8
