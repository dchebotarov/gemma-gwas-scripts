
# Recoding plink PCA eigenvec file to be used as GEMMA covariate file

pcafile=${1?"Please provide an input eigenvec file"}

skip=${2:-0}

>&2  echo "Will skip $skip lines"

awk -v skip="$skip" 'NR > skip { $1=""; $2 = ""; print 1,$0 }' $pcafile


