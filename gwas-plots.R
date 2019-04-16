
# Manhattan plots for LoF gwas data
library(getopt)

if(!interactive()){
  opt = getopt(spec = matrix(c(
    "trait_name",  "t", 2, "character",
    "gwas_result", "f", 2, "character",
    "annot_file",  "a", 2, "character"
  ), byrow = TRUE, ncol=4))
  
  # Parse options
  trait_name = opt$trait_name
  if(is.null(trait_name)){
    trait_name = paste0("Trait-", date())
  }
  gwas_result_file = opt$gwas_result
  if(is.null(gwas_result_file)){
    stop("Please specify GWAS result file as returned by GEMMA (columns chr,rs,ps,p_wald) using -f argument")
  }
  # annotation: need to have "chr", "locus", "start", "stop","annotation"
  annot_file = opt$annot_file
  if(is.null(annot_file)){
    annot_file = "annotations/all.locus_brief_info.7."
  }
  
} else {
  # replace with your own values
  trait_name = "Seedling height"
  gwas_result_file = "output/lmm-SeedlHeight.assoc.txt"
  
  annot_file = "Data/annotations/all.locus_brief_info.7.0"
}

####################
library(readr)
library(qqman)
library(dplyr)


# Load data
gwas = read_table2(gwas_result_file)

# annotation
genes = read_tsv(annot_file)
genes = unique(genes[ genes$is_representative=="Y",
                      c("chr", "locus", "start", "stop","annotation")])


## QQ plot
tiff(filename = paste0(trait_name, "-QQplot.tiff"), 
     width = 5, height = 5, bg = "white", units = "in", res = 300)
  qq(pvector = gwas$p_wald, main=paste0("QQ plot for ", trait_name))
dev.off()

# 
tiff(filename = paste0(trait_name, "-Manhattan-all.tiff"), 
     width = 10, height = 4, bg = "white", units = "in", res = 300)
qqman::manhattan(gwas, chr = "chr", bp = "ps", snp = "rs", p = "p_wald"   
                 #,annotatePval = 7e-7
                 , main = trait_name
                 , ylim = c(0, 0.6 + max(-log10(gwas$p_wald)))
                 )
dev.off()

# gwas[ -log10(gwas$p_wald) > 5, c("rs", "chr", "ps")]
