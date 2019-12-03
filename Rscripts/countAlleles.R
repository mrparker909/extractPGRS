libPath = .libPaths()[1]
if(file.exists("RlibPath.txt")) {
  libPath = paste(readLines("RlibPath.txt"), collapse=" ")
}

if(!require(dplyr, quietly=T, warn.conflicts=F)) { install.packages("dplyr", lib=libPath, dependencies=T,repos = "http://cran.us.r-project.org", quiet=T) }
if(!require(magrittr, quietly=T, warn.conflicts=F)) { install.packages("magrittr", lib=libPath, dependencies=T,repos = "http://cran.us.r-project.org", quiet=T) }
if(!require(pracma, quietly=F, warn.conflicts=F)) { install.packages("pracma", lib=libPath, dependencies=T,repos = "http://cran.us.r-project.org", quiet=T) }

library(dplyr, quietly=T, warn.conflicts=F, lib=libPath)
library(magrittr, quietly=T, warn.conflicts=F, lib=libPath)
library(pracma, quietly=T, warn.conflicts=F, lib=libPath)

args          = commandArgs(trailingOnly=T)
rsIDPath      = args[1] # list of rsIDs to keep
bimPath       = args[2] # folder containing binary files
outputFolder  = args[3] # where to save output files
refAllelePath = args[4] # PGRS allele data
rawPath       = args[5] # merged raw file subsetted by rsIDs to keep

#### DEFINE: function to perform strand check and ambigious allele check
# return 0 if snp needs to be removed,
# return 1 if snp is okay as-is
# return -1 if snp requires strand flip
checkAlleles <- function(refA, refA1, refA2, modA1, modA2) {
  refA1A2 = paste0(refA1,refA2)
  if(refA == refA1) {
    refA1A2 = paste0(refA2, refA1)
    refA1 = refA2
    refA2 = refA
  }

  modA1A2 = paste0(modA1, modA2)

  sign = 1 # default is okay as-is

  if(modA1A2 %in% c("AT", "TA") & refA1A2 %in% c("AT", "TA")) {
    return(0)
  }
  if(modA1A2 %in% c("GC", "CG") & refA1A2 %in% c("GC", "CG")) {
    return(0)
  }

  unionA1A2 = paste0(refA1A2,modA1A2)
  pr = perms(c("A","C","G","T"))
  pr = paste0(pr[,1], pr[,2], pr[,3], pr[,4])

  if(unionA1A2 %in% pr) {
    # strand switch
    modA1A2 = strandSwitch(modA1A2)
    modA1 = substr(modA1A2, 1,1)
    modA2 = substr(modA1A2, 1,1)
  }

  if(refA1 != modA1) {
    # check for allele switch
    modA1 = substr(modA1A2, 2,2)
    modA2 = substr(modA1A2, 1,1)
    modA1A2 = paste0(modA1, modA2)
    sign = -1
  }

  if(refA1A2 != modA1A2) {
    # check for random error, eg AC vs AT
    return(0)
  }

  return(sign)
}
####
strandSwitch <- function(A1A2) {
  A1 = substr(A1A2, 1,1)
  A2 = substr(A1A2, 2,2)
  if(A1 == 'A') {
    A1 = 'T'
  } else if(A1 == 'T') {
    A1 = 'A'
  } else if(A1 =='G') {
    A1 = 'C'
  } else if (A1 == 'C') {
    A1 = 'G'
  }
  if(A2 == 'A') {
    A2 = 'T'
  } else if(A2 == 'T') {
    A2 = 'A'
  } else if(A2 =='G') {
    A2 = 'C'
  } else if (A2 == 'C') {
    A2 = 'G'
  }
  return(paste0(A1,A2))
}
################################

# list of rsIDs to keep
rsIDsToKeep = read.csv(rsIDPath, header=F, stringsAsFactors=F, quote="")[,1]

# get list of .bim files
bimFiles = list.files(path=bimPath, pattern = ".*.bim")

# read and process first file:
rF  = read.table(paste0(bimPath,bimFiles[1]), header = T, sep="\t", stringsAsFactors=F)
colnames(rF) =  c("chromosome", "rsID", "position","coordinate", "A1", "A2")
rF = rF %>% filter(rsID %in% rsIDsToKeep)

# bind columns of each file by IID
for(file in bimFiles[-1]) {
  f = read.table(paste0(bimPath,file), header = T, sep="\t", stringsAsFactors=F)
  colnames(f) =  c("chromosome", "rsID", "position","coordinate", "A1", "A2")
  f = f %>% filter(rsID %in% rsIDsToKeep)

  rF = rbind(rF,f)
}
print(paste0("IDs found in .bim files: ", nrow(rF)))
if(nrow(rF)==0) {
  stop("No SNPs in .bim files match with risk score SNPs. Cannot calculate risk scores.")
}

write.table(x = rsIDsToKeep[-which(rsIDsToKeep %in% rF$rsID)],
            sep="\t", row.names = F, col.names = F, file=paste0(outputFolder,"missing_SNPs.stats"), quote=F)

# read in reference allele data
# keep: rsID ref Beta A1 A2
print("Reading effect allele data...")
refAllele = read.csv(refAllelePath,header=T, sep="\t", stringsAsFactors=F)
refAllele = refAllele %>% select(rsID, ref=EffectAllele, Beta, A1, A2)

# read in RAW file
#rawPath = "/zfs3/users/matthew.parker/matthew.parker/PolygenicRiskScore/PRS_PNC/scripts/output/PNC_292_out_of_336_RAW.raw"
print("Reading .raw file data...")
rawFile = read.table(rawPath, header = T, sep=" ", stringsAsFactors=F)

colnames(rawFile) = sub("_.*", "", colnames(rawFile))

print("Checking for allele mismatch...")
# switch from Allele1 counts to Effect allele counts
changedReference = 0
rsIDsCHANGED = NULL
decision = NULL
for(i in 7:ncol(rawFile)) {
  rs = colnames(rawFile)[i]
  ref = refAllele %>% filter(rsID == rs) %>% .$ref
  refA1 = refAllele %>% filter(rsID == rs) %>% .$A1
  refA2 = refAllele %>% filter(rsID == rs) %>% .$A2
  Allele1 = rF %>% filter(rsID == rs) %>% .$A1
  Allele2 = rF %>% filter(rsID == rs) %>% .$A2
  # if Allele1 is not reference allele
  # CHECK CASES:
  DEC = checkAlleles(ref, refA1, refA2, Allele1, Allele2)

  # make decision
  # -1 = strand flip, 0 = remove snp, +1 = keep alleles unchanged
  decision= c(decision,DEC)
}

changedReference = sum(decision != 1)
rsIDsCHANGED = colnames(rawFile)[-c(1:6)][which(decision != 1)]
print(paste0("Allele mismatches compared to Effect Alleles: ", changedReference))
if(changedReference > 0) {
  write.table(x = data.frame(IDsChanged=rsIDsCHANGED),
              sep=" ", quote=F, row.names = F, col.names = F, file=paste0(outputFolder,"AllelesChangedToEffectAllele.stats"))

}

# use decision to calculate risk score per individual
print(paste0("SNPs excluded: ", sum(decision==0)))

# match betas to snps (removes any snps from refAllele that aren't present in rawFile
rsID_df = data.frame(rsID=colnames(rawFile)[-c(1:6)])
df1 = left_join(rsID_df, refAllele, by="rsID")

# exclude snps if decision==0
include = decision != 0
decision = decision[include]
df1 = df1[include,]

print(paste0("SNPs included: ", sum(include)))

print("Calculating risk scores...")
# calculate score for each individual
IID_df = rawFile[,2]

ones = rep(1, times=length(decision))
MatDec = decision%*%t(ones)
rawMat = as.matrix(rawFile[,-c(1:6)])
rawMat = rawMat[,include]

scores = NULL
if(length(df1$Beta) == 0) { # no SNPs passed quality control
  stop("No SNPs passed quality control, cannot calculate risk scores.")
} else if(length(df1$Beta) ==1) { # one SNP passed qc
  warning("Only one SNP passed quality control, risk scores calculated from single SNP Beta.")
  scores = as.numeric(rawMat) * as.numeric(MatDec) * as.numeric(df1$Beta)
  scores = as.data.frame(scores)
} else {
  scores = rawMat %*% MatDec %*% as.numeric(df1$Beta)
}

df2 = data.frame(IID=rawFile[,2], RiskScore=scores[,1])

# output file with two columns: IID, RiskScore
write.table(x = df2, file = paste0(outputFolder,"RiskScores.tsv"), row.names=F, col.names=T, quote=F, sep="\t")
