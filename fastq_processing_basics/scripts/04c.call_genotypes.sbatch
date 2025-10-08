#!/bin/bash 
#
#SBATCH --job-name=genomedb
#SBATCH --output=genomedb.%j.out
#SBATCH --error=genomedb.%j.err
#################
#SBATCH -t 1:00:00
#SBATCH -p amilan
#SBATCH --qos=normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node 4
#SBATCH --mem=16G
#################
#SBATCH --array=1-4
#################
#SBATCH --mail-type=END,FAIL
#SBATCH  --mail-user=ericacnr@colostate.edu
#################
#echo commands to stdout

set -x

source ~/.bashrc
conda activate gatk_4

##To prepare the comm_lines.txt file, choose one bam file
#samtools view -H bam_file | sed 's/SN://g; s/LN://g' | awk '/^@SQ/' | awk -f assemble-scaffold-lists.awk > AMRE.4m.comm_lines.txt

REFERENCE="resources/reference/mini-test-genome.fna"
GVCF="/scratch/alpine/cbossu@colostate.edu/LOSH/GVCF"
COMMS="vcf/comm_lines.txt"
OUTN=$(printf '%04d' $SLURM_ARRAY_TASK_ID)
OUT=$OUTN

SEG=$(awk -F"\t" -v n=$SLURM_ARRAY_TASK_ID 'NR == n {print $2}' $COMMS)
     
#Genotype all GVCF files

mkdir -p vcf/unfilt_genotypes_HC

java -Djava.io.tmpdir=/scratch/alpine/ericacnr@colostate.edu/tmp -Xmx37g -jar /curc/sw/install/bio/gatk/4.3.0.0/gatk-package-4.3.0.0-local.jar  GenotypeGVCFs \
   -R $REFERENCE \
   -V gendb://vcf/called_genotypes_HC/${SLURM_ARRAY_TASK_ID}_gcrf_database \
   -O vcf/unfilt_genotypes_HC/${OUT}_HC_genotypes_unfiltered.vcf.gz > vcf/$OUT.stdout 2> vcf/$OUT.stderr