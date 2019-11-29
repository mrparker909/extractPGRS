library("dplyr", quietly=T, warn.conflicts=F)
library("magrittr", quietly=T, warn.conflicts=F)

args = commandArgs(trailingOnly=T)
in1 = args[1] # atlas file, eg snps file
in2 = args[2] # atlas file, eg imputed or genotyped file

df1 = read.table(in1, stringsAsFactors=F, sep="\t", header=T)
df2 = read.table(in2, stringsAsFactors=F, sep="\t", header=T)

print("Joining atlas snp file with atlas genotype file...")
df3 = left_join(df1,df2, by=c("rsID"))

write.table(df3, "./tmp/ATLAS_JOINED.tmp", quote=F, sep="\t", row.names=F)
