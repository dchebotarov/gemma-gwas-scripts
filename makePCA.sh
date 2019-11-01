
root=$1
outbase=pca_${root##*/}

mkdir -p PCA
plink --bfile $root  --keep-allele-order --pca 10 header --out PCA/$outbase

# add less PCA for plink GLM

./pca2covar-gemma.sh PCA/$outbase.eigenvec 1  | tr -s " " > PCA/pca_for_gemma.txt

cut -d" " -f1-6 PCA/pca_for_gemma.txt > PC1-5.txt

# cut -d" " -f1-4 PCA/pca_for_gemma.txt > PC1-3.txt

