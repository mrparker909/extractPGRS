library("dplyr", quietly=T, warn.conflicts=FALSE)
library("magrittr", quietly=T, warn.conflicts=FALSE)
library("argparser", quietly=T, warn.conflicts=FALSE)
# command args are:
# [1] atlas file to filter
# [2] pval threshold for filtering
# [3] index

# Create a parser
p <- arg_parser("Filter atlas file SNPs based on p-value threshold.")

# Add command line arguments
p <- add_argument(p, "--atlasFile", help="Atlas polygenic risk score weights file", type="character")
p <- add_argument(p, "--pvalue", help="pvalue threshold above which SNPs will be excluded from the polygenic risk score", default=0.000005)
p <- add_argument(p, "--index", help="index used for multiple atlas files (eg chromosomes 1 through 22), prevents overwriting of atlas.tmp file", type="numeric", default=0)

# Parse the command line arguments
argv <- parse_args(p)

inFile = argv$atlasFile
pval   = argv$pvalue
ind    = argv$index

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
