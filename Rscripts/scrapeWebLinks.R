LIBPATH = .libPaths()[1]
if(file.exists("RlibPath.txt")) {
  LIBPATH = paste(readLines("RlibPath.txt"), collapse=" ")
}

library(selectr, lib=LIBPATH)
library(xml2,    lib=LIBPATH)
library(rvest,   lib=LIBPATH)
library(stringr, lib=LIBPATH)

# input trait number on command line
args = commandArgs(trailingOnly = T)
TRAIT_NUM = args[1]

# retrieve list of links on trait page
page  <- read_html(paste0("http://geneatlas.roslin.ed.ac.uk/downloads/?traits=",TRAIT_NUM))
links <- page %>% html_nodes("a") %>% html_attr("href")

# imputed links:
imp_links     = links[stringr::str_which(links,pattern = "/imputed\\.")]
chr_imp_links = imp_links[1:22]

# imputed snp links:
imp_snp_links = links[stringr::str_which(links, pattern = "snps\\.imputed")]
snp_imp_links = imp_snp_links[1:22]

# download files:
i = 1
for(li in chr_imp_links) {
  download.file(url = li, destfile = paste0("./atlasFiles/imputed.chr",i,".csv.gz"))
  i = i+1
}

i = 1
for(li in snp_imp_links) {
  download.file(url = li, destfile = paste0("./atlasFiles/snps.imputed.chr",i,".csv.gz"))
  i = i+1
}

# unzip files
FILES = list.files("./atlasFiles/", full.names = T)
for(fi in FILES) {
  R.utils::gunzip(fi)
}
