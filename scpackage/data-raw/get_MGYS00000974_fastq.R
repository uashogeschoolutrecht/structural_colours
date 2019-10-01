#not done

test = "wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR833/ERR833281/ERR833281.fastq.gz"
system(test)
move_test = "mv ERR833281.fastq.gz inst/extdata"
system(move_test)
