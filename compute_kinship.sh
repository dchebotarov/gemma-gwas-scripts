

inbase=$1

make_kinship_fam(){
  inputfam=$1
  awk '{$6=777.77; print $0 }' $inputfam > ${inputfam}_kinship
}

make_kinship_fam  ${inbase}.fam 

cp ${inbase}.fam ${inbase}.fam_orig

cp ${inbase}.fam_kinship ${inbase}.fam

mkdir -p kinship

gemma -gk 1 -bfile $inbase -outdir kinship 


