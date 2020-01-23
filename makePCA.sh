
root=$1
outbase=pca_${root##*/}

pca2gemma(){
  pcafile=${1?"Please provide an input eigenvec file"}

  skip=${2:-0}

  >&2  echo "Will skip $skip lines"

  awk -v skip="$skip" 'NR > skip { $1=""; $2 = ""; print 1,$0 }' $pcafile | tr -s " "

}

mkdir -p PCA
plink --bfile $root  --keep-allele-order --pca 10 header --out PCA/$outbase

# add less PCA for plink GLM

 pca2gemma PCA/$outbase.eigenvec 1  > PCA/pca_for_gemma.txt


cut -d" " -f1-2 PCA/pca_for_gemma.txt > PC1.txt
cut -d" " -f1-3 PCA/pca_for_gemma.txt > PC1-2.txt
cut -d" " -f1-4 PCA/pca_for_gemma.txt > PC1-3.txt
cut -d" " -f1-5 PCA/pca_for_gemma.txt > PC1-4.txt
cut -d" " -f1-6 PCA/pca_for_gemma.txt > PC1-5.txt

