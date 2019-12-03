cFiles = list.files(pattern="./tmp/atlas\\.tmp")

if(!length(cFiles > 0)) { stop("ERROR: atlas.tmp* file(s) not found") }

df = read.table(cFiles[1], sep="\t", header=T, quote="", row.names=F, stringsAsFactors=F)
for(fi in cFiles[-1]) {
  df1 = read.table(cFiles[fi], sep="\t", header=T, quote="", row.names=F, stringsAsFactors=F)
  df = rbind(df,df1)
}

write.table(df, "tmp/atlas_cat.tmp", quote=F, sep="\t",row.names=F)

##
cFiles = list.files(pattern="./tmp/atlas\\.snp\\.tmp*")

if(!length(cFiles > 0)) { stop("ERROR: atlas.snp.tmp* file(s) not found") }

df = read.table(cFiles[1], sep="\t", header=T, quote="", row.names=F, stringsAsFactors=F)
for(fi in cFiles[-1]) {
  df1 = read.table(cFiles[fi], sep="\t", header=T, quote="", row.names=F, stringsAsFactors=F)
  df = rbind(df,df1)
}

write.table(df, "tmp/atlas.snp_cat.tmp", quote=F, sep="\t",row.names=F)
