#!/bin/Rscript

args = commandArgs(TRUE)

# Prepare .fam for running GWAS with gemma or PLINK

cat("Usage: <script>  <fam> <phenofile> \n Pheno file has 1 column for ID and   \n")

fam_file = args[[1]]
pheno_file =  args[[2]]  

# Load FAM
fam = read.table(fam_file, stringsAsFactors = F, header = F, comment="")
names(fam) = c("FID", "IID", "F", "M", "S", "PHENO")
fam$order = 1:nrow(fam)
rownames(fam) = fam$IID

# Load phenotype dataset
Pheno = read.table(pheno_file, stringsAsFactors = F, header=T, comment="")
# List of all traits
trait_names = names(Pheno)[-1]
names(Pheno)[[1]] = "ID"

# Loop over traits
for(trait_name in trait_names ){
  trait = Pheno[, c("ID", trait_name)]
  # Remove NA
  trait = trait[ !is.na(trait[,2]), ]

  cat("Trait ", trait_name, " has ", sum(!is.na(trait[,2] )), " observations.\n" )

  if(nrow(trait) < 200) next

  # Merge
  fam_ph = merge(fam, trait, by.x=2 , by.y = 1, sort=F, all.x=TRUE)
  fam_ph$PHENO = fam_ph[[ trait_name ]]
  fam_ph = fam_ph[ order(fam_ph$order), c(1:7) ]
  stopifnot( all(fam_ph$order ==1:nrow(fam)))
  fam_ph = fam_ph[, 1:6]
  # Save
  outname = paste0(fam_file, ".", trait_name, ".txt")
 outname_1 = paste0("pheno1col-", fam_file, ".", trait_name, ".txt")
  write.table(fam_ph, outname, row.names = F, col.names = F, quote=F, sep=" ")
  # Also save as one-column file
  write.table(fam_ph[[6]], outname_1, row.names = F, col.names = F, quote=F, sep=" ")
}

