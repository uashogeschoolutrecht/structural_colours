#' Runs metaphlan2.py on fastq files to assign taxonomy
#'
#' @param input fastq file path
#'
#' @return
#' @export
#'
#' @examples
q2_metaphlan2 <- function(input1 , out) {
  #make dir ~/scpackage/metaphlan_db
  if(!dir.exists("~/scpackage/metaphlan_db")) {
    dir.create("~/scpackage/metaphlan_db")
  }
  command = paste0("/opt/conda/envs/q2-metaphlan2/bin/metaphlan2.py ", input1, " --input_type fastq ", "--bowtie2db ~/scpackage/metaphlan_db", " --bowtie2out ~/scpackage/metagenome3.bowtie2.bz2 > ", out)
  print("Running following command in shell:")
  print(command)
  system(command)
}

#q2_metaphlan2("~/scpackage/inst/extdata/SRR7778149.1_1.fastq", "~/scpackage/inst/extdata/SRR7778149.1_2.fastq")
q2_metaphlan2("~/scpackage/inst/extdata/SRR7778149.1.fastq", out="metaphlan_interleaved3.txt")

/opt/conda/envs/q2-metaphlan2/bin/metaphlan2.py ~/scpackage/metagenome2.bowtie2.bz2 --bowtie2db ~/scpackage/metaphlan_db --input_type bowtie2out > metaphlan_interleaved2.txt

/opt/conda/envs/q2-metaphlan2/bin/metaphlan2.py ~/scpackage/inst/extdata/SRR7778149.1_1.fastq,~/scpackage/inst/extdata/SRR7778149.1_2.fastq --bowtie2db ~/scpackage/metaphlan_db --input_type fastq --bowtie2out ~/scpackage/metagenome4.bowtie2.bz2> test4

