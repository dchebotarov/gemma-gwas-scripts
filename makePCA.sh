
root=$1
mkdir -p PCA
plink --bfile $root  --keep-allele-order --pca 10 header --out PCA/pca_$root


./pca2covar-gemma.sh PCA/pca_$root.eigenvec 1  | tr -s " " > PCA/pca_for_gemma.txt

cut -d" " -f1-6 PCA/pca_for_gemma.txt > PC1-5.txt

