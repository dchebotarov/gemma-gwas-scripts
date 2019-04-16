#!/bin/bash


usage() { 
	echo "Usage: $0 plink_root kinship [ -c covariate ] [-p phenotype ] [-H phenotype has header] [-t trait_name] ";
	exit 1 ;
	}

if [ $# -lt 2 ] ; then
 usage
fi

### Required positional args

# Plink genotype file
geno=$1 ; shift

# Kinship
kinship=$1 ; shift

## Optional args
while getopts "c:p:Ht:o:" opt ; do
	case $opt in 
		c)  # COvariate file
			covar_opt= " -c ${OPTARG} "
			;;
		p)  # Phenotype file
			pheno_file=${OPTARG}
			;;
		H)  # Pheno file has header
			pheno_has_header=1
			;;
		t) # Trait name
			trait_name=${OPTARG}
			;;
		o) # Output base
			outbase=${OPTARG}
			;;
		*)
			usage
			;;
	esac
done

shift $((OPTIND-1))

			


# Covariate file
#covar=$1 ; shift

if [ -z "$trait_name" ] ; then
	trait_name="Trait-"` date "+%m%d-%H%M.%S"`
fi

# Output file "basename" (may add suffixes to this)
#outbase=${1:-gemma-result} ; shift
if [ -z "$outbase" ] ; then
	outbase="lmm-$trait_name"
fi


famfile=${geno}.fam

# Trait file
# If no trait file is given, put a message "using the phenotype inside PLINK fam file"
if [ ! -z "$pheno_file" ] ; then
	if [ ! -f "$pheno_file" ] ; then
		echo "$pheno_file not found"
		exit -1
	fi
	>&2 echo "Using phenotype file $pheno_file"

	# Backup original fam
	cp $famfile ${famfile}.orig
	
	# Make sure the trait file has the same sample order as the original fam file
	discord_samples=`awk -v H="$pheno_has_header" 'NR > H {print $1,$2}' $pheno_file | paste - $famfile | awk '($1 != $3) || ($2 != $4)' | head  `
	echo $discord_samples
	if [ ! -z "$discord_samples" ] ; then
		echo "Samples in phenotype file $pheno_file  do not have the same order as in PLINK .fam file $famfile "
		echo "If the phenotype file has a header line, please indicate that by flag -H"
		exit -2
	fi

	# Replace the fam file by the pheno fam file
	if [ -z "$pheno_has_header" ]  ; then
		cp $pheno_file $famfile
	else 
		tail -n+2 $pheno_file > $famfile
	fi
	replaced=$?
	#fam_repl="tail -n+$(($pheno_has_header + 0))  $pheno_file > $famfile"
	>&2 echo "Replacinf $famfile by $pheno_file"
	#$fam_repl

else
	>&2 echo "Using phenotype info in the .fam file ${geno}.fam"
fi


# Actual command 

command="gemma -lmm -bfile $geno -k $kinship -o ${outbase} ${covar_opt}"

>&2 echo "Executing: $command "

$command

if [ ! -z "$replaced" ] ; then
	cp ${famfile}.orig $famfile
fi



