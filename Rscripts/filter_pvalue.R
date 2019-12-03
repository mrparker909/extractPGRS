
LIBPATH = .libPaths()[1]
if(file.exists("RlibPath.txt")) {
  LIBPATH = paste(readLines("RlibPath.txt"), collapse=" ")
}

if(!require(dplyr, quietly=T, warn.conflicts=F)) { install.packages("dplyr", lib=LIBPATH, dependencies=T,repos = "http://cran.us.r-project.org", quiet=T) }
if(!require(magrittr, quietly=T, warn.conflicts=F)) { install.packages("magrittr", lib=LIBPATH, dependencies=T,repos = "http://cran.us.r-project.org", quiet=T) }

library("dplyr", quietly=T, warn.conflicts=FALSE, lib=LIBPATH)
library("magrittr", quietly=T, warn.conflicts=FALSE, lib=LIBPATH)

# command args are:
# [1] atlas file to filter
# [2] pval threshold for filtering
# [3] index
args   = commandArgs(trailingOnly=T)
inFile = args[1]
pval   = as.numeric(args[2])
ind    = as.integer(args[3])

dat1 = NULL
dat2 = NULL

if(!grepl("snps\\..*", inFile)) {
  # snp file containing A1 and A2
  dat1 = read.table(inFile, header=T, sep=" ", stringsAsFactors=F)

  # we can tell if file is IMPUTED, because has extra column: "iscore"
  if(ncol(dat1) == 6) {
    colnames(dat1) =c("rsID", "EffectAllele", "iscore", "Beta", "BetaSE", "PVAL")
  } else {
    colnames(dat1) =c("rsID", "EffectAllele", "Beta", "BetaSE", "PVAL")
  }
  nr1 = nrow(dat1)
  df = dat1 %>% filter(PVAL <= pval)
  nr2 = nrow(df)
  statStr = paste0("SNPs remaining after p-value (", pval, ") thresholding: ", nr2)
  write.table(statStr, paste0("./tmp/SNPsAfterThresh",ind,".stats"), row.names=F, col.names=F, sep=" ", quote=F)
  write.table(df, paste0("./tmp/atlas.tmp",ind), row.names=F, sep="\t", quote=F)
} else {
  # genotype file containing EffectAllele
  dat2 = read.table(inFile, header=T, sep=" ", stringsAsFactors=F) %>% rename(rsID=SNP)
  write.table(dat2, paste0("./tmp/atlas.snp.tmp",ind), row.names=F, sep="\t", quote=F)
}
