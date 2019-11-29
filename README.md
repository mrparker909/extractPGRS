# extractPGRS
Set of scripts for extracting polygenic risk scores data from http://geneatlas.roslin.ed.ac.uk/ genomics files.

## Gene Atlas: 

http://geneatlas.roslin.ed.ac.uk

## extractPGRS.sh

Script:
 INPUTS:  inputFolder (location for gene atlas PGRS files (eg chr1.csv, snp.chr1.csv, ..., chr22.csv, snp.chr22.csv)
          binariesFolder (bed/bim/fam file location for merged binaries for which to calculate risk scores)
          alpha (p-value cutoff for risk scores)
          outFolder (path for output PGRS file)
 OUTPUTS: tsv file with 2 columns: IID, PGRS
          various stats files

 EXAMPLE:
sh extractPGRS.sh atlasFiles/ binaryFiles/ 0.000005 output/

 Directory structure for example:
| script/directory
| - script.sh
| - | Rscripts
  - | - various R scripts
| - | atlasFiles
    | - chr1.csv, ..., chr22.csv
    | - snp.chr1.csv, ..., snp.chr22.csv
| - | binaryFiles
    | - PNCchr1.bim, PNCchr1.bed, PNCchr1.fam, ..., PNCchr22.bim, PNCchr22.bed, PNCchr22.fam
| - | output
| - | tmp

