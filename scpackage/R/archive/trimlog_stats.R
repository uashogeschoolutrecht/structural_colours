filepath = "/home/patty_rosendaal/research_drive/geodescent/samples/MGYS00000974/trimmed/logs/ERR833273_log"
library(data.table)

file = fread(filepath, sep = " ")
head(file)


#Specifying a trimlog file creates a log of all read trimmings, indicating the following details:
#  the read name
#the surviving sequence length
#the location of the first surviving base, aka. the amount trimmed from the start
#the location of the last surviving base in the original read
#the amount trimmed from the end


trimmed_end = sum(file$V6)
trimmed_start = sum(file$V4)
after_length = sum(file$V3)
before_length = after_length + trimmed_end + trimmed_start

kept_perc = after_length/before_length * 100
