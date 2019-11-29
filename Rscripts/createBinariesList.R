args = commandArgs(trailingOnly=T)
binaryFolder = args[1]
tempFolder   = args[2]

bFiles = list.files(binaryFolder, full.names=T)
bFiles = gsub('.{4}$', '', bFiles)
bFiles = unique(bFiles)

write(bFiles, paste0(tempFolder,"binariesList.txt"), sep="\n")
