library(gbtools)
install.packages('gbtools')
library(devtools)
install_github("kbseah/genome-bin-tools/gbtools")

d <- gbt(covstats="/home/rstudio/test_covstats.txt")
plot(d)

bin1.contigNames <- scan(file="/home/rstudio/mapped.metabat.1.contigNames",what=character())
bin20.contigNames <- scan(file="/home/rstudio/sample.metabat.20.contigNames",what=character())
d.bin1 <- gbtbin(shortlist=bin1.contigNames,x=d,slice=NA)
d.bin20 <- gbtbin(shortlist=bin20.contigNames,x=d,slice=NA)

plot(d, textlabel = T)
points(d.bin1, col='red', slice=1)
multiBinPlot(d, d.bin1)
plot(d.bin1)
points(d.bin20,col="green",slice=1)
