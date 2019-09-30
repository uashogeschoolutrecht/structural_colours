#get protein assembly IR1
command = "wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/002/277/835/GCA_002277835.1_ASM227783v1/GCA_002277835.1_ASM227783v1_protein.faa.gz"
system(command)
command2 = "mv GCA_002277835.1_ASM227783v1_protein.faa.gz inst/extdata/"
system(command2)
command3 = "gunzip inst/extdata/GCA_002277835.1_ASM227783v1_protein.faa.gz"
system(command3)
