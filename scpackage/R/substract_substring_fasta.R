
file = "/home/rstudio/scpackage/inst/extdata/hit_contig.txt"
out = "/home/rstudio/scpackage/inst/extdata/hit_range.txt"

file = readLines(con = file)

seq = ""
count = 0
for (line in file){
  if (count > 0){
    seq = paste0(seq, line)
  }
  count = count + 1
}

hit = substr(seq, start = 244, stop = 1641)
write(hit, file = out)
