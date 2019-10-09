# get SRA file for compost metagenome with M17 hit
command1 = 'wget https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos/sra-pub-run-1/SRR7778149/SRR7778149.1'
system(command1)

# move to inst/extdata
command2 = 'mv SRR7778149.1 inst/extdata/'
system(command2)
