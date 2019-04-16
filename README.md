# gemma-gwas-scripts
A collection of scripts to aid mixed linear model based GWAS with GEMMA

## Prerequisites
You need to have the following installed
 -  PLINK 1.90 ( https://www.cog-genomics.org/plink2/ )
 - gemma (https://github.com/genetics-statistics/GEMMA )
 - R (>=3.3))

##  Typical workflow

#### Inputs 
 - A binary PLINK dataset (.bed,.bim,.fam) and
 - a phenotype file (with sample IDs in the first column and one or more phenotypes in subsequent columns). The header line should have unique names for phenotypes


####  Workflow 

Assuming one has a genotype dataset mydata.bed/bim/fam and a phenotype file pheno.txt with columns ID, Trait1, Trait2

 1. Create necessary files for MLM GWAS (i.e. kinship matrix)
```
 ./compute_kinship.sh mydata
```
This creates a file result.cXX.txt in the directory ./kinship


Optionally, also compute principal components to be used as covariates
```
./makePCA.sh mydata
```

 2. Prepare datasets for each trait
```
Rscript add-pheno-to-fam.R mydata.fam pheno.txt
```

 3. Run GWAS

```
./RunGemma.sh mydata kinship/result.cXX.txt -p mydata.fam.Trait1.txt -t Trait1
```
This creates a directory `output` and places a file `output/lmm-Trait1.assoc.txt`  (the GWAS result) as well as a log file.

There are  additional options for RunGemma.sh 
```
./RunGemma.sh plink_root kinship [ -c covariate ][-p phenotype ][-H phenotype has header][-t trait_name]
```

 4. Plot results
```
 Rscript gwas-plots.R -t Trait1  -f output/lmm-Trait1.assoc.txt
```
Arguments: 
 - -f : GWAS output file
 - -t : trait name to appear on plots

