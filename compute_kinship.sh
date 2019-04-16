

inbase=$1

./make_kinship_fam.sh ${inbase}.fam 

cp ${inbase}.fam ${inbase}.fam_orig

cp ${inbase}.fam_kinship ${inbase}.fam

mkdir -p kinship
gemma -gk 1 -bfile $inbase -outdir kinship 


