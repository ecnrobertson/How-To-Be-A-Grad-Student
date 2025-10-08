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

#running from the head directory 01.fastq_processing
GVCF="vcf/raw_genotypes_HC"
COMMS="vcf/comm_lines.txt"

OUTN=$(printf '%04d' $SLURM_ARRAY_TASK_ID)
OUT=$OUTN

SEG=$(awk -F"\t" -v n=$SLURM_ARRAY_TASK_ID 'NR == n {print $2}' $COMMS)

## Consolidate all GVCF files
#This step consists of consolidating the contents of GVCF files across all of your samples in order to improve scalability and speed the next step, joint genotyping. We will use the GenomicsDBImport tool and will need to make a new temporary directory.

mkdir -p vcf/called_genotypes_HC

java -Djava.io.tmpdir=/scratch/alpine/ericacnr@colostate.edu/tmp -Xmx37g -jar /curc/sw/install/bio/gatk/4.3.0.0/gatk-package-4.3.0.0-local.jar GenomicsDBImport \
   $(printf ' --variant %s ' $GVCF/*g.vcf) \
     --genomicsdb-workspace-path vcf/called_genotypes_HC/${SLURM_ARRAY_TASK_ID}_database \
      $SEG > vcf/$OUT.stdout 2> vcf/$OUT.stderr