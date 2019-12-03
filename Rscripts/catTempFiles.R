cFiles = list.files(path="./tmp", pattern="atlas\\.tmp*", full.names=T)

if(!length(cFiles > 0)) { stop("ERROR: atlas.tmp* files not found") }

df = read.table(cFiles[1], sep="\t", header=T, quote="", stringsAsFactors=F)
for(fi in cFiles[-1]) {
  df1 = read.table(fi, sep="\t", header=T, quote="", stringsAsFactors=F)
  df = rbind(df,df1)
}

write.table(df, "tmp/atlas_cat.tmp", quote=F, sep="\t",row.names=F)

##
cFiles = list.files(path="./tmp", pattern="atlas\\.snp\\.tmp*", full.names=T)

if(!length(cFiles > 0)) { stop("ERROR: atlas.snp.tmp* files not found") }

df = read.table(cFiles[1], sep="\t", header=T, quote="", stringsAsFactors=F)
for(fi in cFiles[-1]) {
  df1 = read.table(fi, sep="\t", header=T, quote="", stringsAsFactors=F)
  df = rbind(df,df1)
}

write.table(df, "tmp/atlas.snp_cat.tmp", quote=F, sep="\t",row.names=F)
