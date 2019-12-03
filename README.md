# extractPGRS

   Set of scripts for extracting polygenic risk scores data from http://geneatlas.roslin.ed.ac.uk/ genomics files.

## Gene Atlas: 

   http://geneatlas.roslin.ed.ac.uk

## extractPGRS.sh
```
Script:
 INPUTS:  inputFolder (location for gene atlas PGRS files (eg chr1.csv, snp.chr1.csv, ..., chr22.csv, snp.chr22.csv)
          binariesFolder (bed/bim/fam file location for merged binaries for which to calculate risk scores)
          alpha (p-value cutoff for risk scores)
          outFolder (path for output PGRS file)
 OUTPUTS: tsv file with 2 columns: IID, PGRS
          various stats files

 EXAMPLE:
sh extractPGRS.sh atlasFiles/ binaryFiles/ 0.000005 output/
```

```
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
```

## Instructions

### 0) Clone Repo
   
   This repository contains all the necessary scripts and the recommended folder structure.
   
   Clone this repo to your working directory:
```
git clone https://github.com/mrparker909/extractPGRS
```

### 1) Prerequisite Software

   Software:
```
- plink2
- R
```

   R Packages:
```
- dplyr
- magrittr
- stringr
- rvest
```

   Note 1: the file "RlibPath.txt" is used to specify the location to which the libraries are installed, and can be deleted if the libraries are installed at .libPaths()[1]. This is to allow running the script on a remote cluster without library path write permissions.

   Note 2: the packages "stringr" and "rvest" are used for web scraping to automate downloading of the GeneAtlas files, and are not necessary if you will be manually downloading the files.

### 2) Necessary Files

#### Gene Atlas:

   First choose a trait to calculate a risk score for, this can be done here: http://geneatlas.roslin.ed.ac.uk/trait/

   Once you have chosen a trait, the trait number is shown in the URL (eg: trait number is 76 for "depression"): http://geneatlas.roslin.ed.ac.uk/trait/?traits=76 
   
   The files needed are the imputed genotype files (under the column "Imputed Results") and the imputed genotype snp files (under the column "Variants" immediately after the "Imputed Results" column) for each chromosome included in the study (see the image below).

   ![geneAtlasImage](https://github.com/mrparker909/extractPGRS/blob/master/geneAtlasDownload_markedup.png)

   These can be downloaded manually, or using the script "./Rscripts/scrapeWebLinks.R", inputing the trait number for the desired trait like so (in this example trait number=76):
```
Rscript ./Rscripts/scrapeWebLinks.R 76
```

The files for chromosomes 1-22 will be automatically downloaded into the "./atlasFiles/" folder.

#### Study Population:

   For the population you are calculating risk scores for, you will need .bim .bed and .fam files for each of the chromosomes you will be including in the study. These files should be placed in the "./binaryFiles/" folder, with no other files present. Alternatively they may be placed in another directory, but still must be the only files present in the directory.

### 3) Run extractPGRS.sh

   Either submit run.sh to a job scheduler for remote computing, or run extractPGRS.sh locally:
```
sh extractPGRS.sh atlasFiles/ binaryFiles/ 0.000000005 output/
```

   The first argument (in this case "atlasFiles/") is the location of the downloaded and unzipped GeneAtlas files (2 files per chromosome). 
   
   The second argument (in this case "binaryFiles/") is the location of the study population .bim/.bed/.fam files (3 files per chromosome).

   The third argument (in this case "0.000000005") is the p-value threshold for including SNPs in the risk score calculation.

   The fourth argument (in this case "output/") is the location to place output files (such as the calculated risk scores).
