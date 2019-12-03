#!/bin/bash

echo "INPUT PARAMETERS:"
echo 'inputFileFolder = ' $1
echo 'binaryFileFolder = ' $2
echo 'p-value cutoff = ' $3
echo 'outputFolder = ' $4

module load plink2
module load R/3.5.0

mkdir -p tmp

i=1
for f in $1/*
do
  echo "Processing file ${i}: ${f}"

  # create ./tmp/atlas.tmp${i}
  # create ./tmp/atlas.snp.tmp${i}
  Rscript ./Rscripts/filter_pvalue.R ${f} $3 ${i}

  i=`expr $i + 1`
done
echo "Done processing atlasFiles"

echo "Concatenating atlas.tmp* files..."
# concatenate output tempFiles into tempFile_cat
Rscript ./Rscripts/catTempFiles.R
cat ./tmp/atlas_cat.tmp | cut -f1 | tail -n +2  > ./tmp/ATLASrsID.txt

# join atlas_cat.tmp with atlas.snp_cat.tmp (we need A1 and A2 from snp files)
Rscript ./Rscripts/join_atlas.R ./tmp/atlas_cat.tmp ./tmp/atlas.snp_cat.tmp

echo "Creating list of binary files..."
Rscript ./Rscripts/createBinariesList.R $2 ./tmp/

echo "Merging binaries and extracting rsIDs..."
plink --merge-list ./tmp/binariesList.txt --extract ./tmp/ATLASrsID.txt --make-bed --out ./tmp/tmp

echo "Creating RAW file..."
plink --bfile ./tmp/tmp --recode A --out ./tmp/tmp

echo "Checking for mislabelled Alleles..."
Rscript ./Rscripts/countAlleles.R ./tmp/ATLASrsID.txt $2 $4 ./tmp/ATLAS_JOINED.tmp ./tmp/tmp.raw

echo "DONE"
