
library(getopt)

if(!interactive()){
  opt = getopt(spec = matrix(c(
    "trait_name",  "t", 2, "character",
    "gwas_result", "f", 2, "character",
    "annot_file",  "a", 2, "character",
    "chromosome", "c", 1, "character",
    "start",    "s", 1, "integer",
    "end", "e", 1, "integer"
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
    annot_file = "annotations/all.locus_brief_info.7.0"
  }
  chromosome = opt$chromosome
  if(is.null(chromosome)){
    stop("Please specify chromosome.\n")
  }
  start = opt$start
  if(is.null(start)){
    start = 0
  }
  end = opt$end
  # if null, whole chromosome
  
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
gw = read_table2(gwas_result_file)

        if(!("P" %in% names(gw) ) & (! "p_wald" %in% names(gw)) ){
          gw = read_table2(gwfile)
        }
        if("P" %in% names(gw)){
          names(gw)[ names(gw)=="P"]="p_wald"
        }

        if("EMP1" %in% names(gw)){
          names(gw)[ names(gw)=="EMP1"]="p_wald"
        }

        gw$logp = -log10(gw$p_wald)
        if("CHR" %in% names(gw)){
          names(gw)[ names(gw)=="CHR"]="chr"
        }
        if("BP" %in% names(gw)){
          names(gw)[ names(gw)=="BP"]="ps"
        }
        if("SNP" %in% names(gw)){
          names(gw)[ names(gw)=="SNP"]="rs"
        }
gwas=gw

gwas = gwas[ !is.na(gwas$p_wald) ,]

# Filtering by region
if (is.integer(gwas$chr)){
  chromosome = as.integer(gsub("chr", "", chromosome))
}
gwas = gwas[ gwas$chr == chromosome, ]

# if given start and end
if(!is.null(end)){
  gwas = gwas[ 
    gwas$ps >= start &
      gwas$ps <= end,
    ]
}


if(nrow(gwas)==0){
  stop("No SNPs remain after filtering!")
}

# annotation
#genes = read_tsv(annot_file)
#genes = unique(genes[ genes$is_representative=="Y",
#                      c("chr", "locus", "start", "stop","annotation")])


## QQ plot
#png(filename = paste0(trait_name, "-QQplot.png"), 
#     width = 5, height = 5, bg = "white", units = "in", res = 300)
#  qq(pvector = gwas$p_wald, main=paste0("QQ plot for ", trait_name))
#dev.off()

# 
if(!is.null(end)){
  xlim = c(start/1e6, end/1e6)
} else {
  xlim = c(0, max(gwas$ps/1e6) )
}

png(filename = 
      paste0(trait_name, "-manh-", 
             chromosome, "_", 
             format(start/1e3, digits = 2), "-",
             format(end/1e3, digits = 2) , "kb",
             ".png"), 
     width = 8, height = 5, bg = "white", units = "in", res = 300)
qqman::manhattan(gwas, chr = "chr", 
                 bp = "ps", snp = "rs", 
                 xlim = xlim,
                 p = "p_wald"   
                 #,annotatePval = 7e-7
                 , main = trait_name
                 , suggestiveline = 5
                 , genomewideline = 6
                 , ylim = c(0, 0.6 + max(-log10(gwas$p_wald), na.rm=T))
                 )
dev.off()

# gwas[ -log10(gwas$p_wald) > 5, c("rs", "chr", "ps")]
