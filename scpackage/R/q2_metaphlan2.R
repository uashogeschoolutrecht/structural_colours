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

system("conda activate q2-metaphlan2")
system("metaphlan2.py ~/scpackage/inst/extdata/SRR7778149.1_1.fastq,~/scpackage/inst/extdata/SRR7778149.1_2.fastq --input_type fastq --bowtie2out ~/scpackage/metagenome8.bowtie2.bz2 > test8")
#--bowtie2db ~/scpackage/metaphlan_db


