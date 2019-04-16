
inputfam=$1

awk '{$6=777.77; print $0 }' $inputfam > ${inputfam}_kinship


