#!/bin/bash
#
#SBATCH --job-name=gvcf
#SBATCH --output=gvcf.%j.out
#SBATCH --error=gvcf.%j.err
#################
#SBATCH -t 8:00:00
#SBATCH -p amilan
#SBATCH --qos=normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node 2
#SBATCH --mem=7G
#################
#SBATCH --mail-type=END
#SBATCH  --mail-user=ericacnr@colostate.edu
##################
#echo commands to stdout
set -x

#run from vcf/unfilt_genotypes_HC/
##for vcf in `ls *vcf.gz | cut -f 1 -d '_'`; do echo $vcf; sbatch ../../04d.mark_dp0_missing.sbatch $vcf; done
source ~/.bashrc
conda activate bioinf

vcf=$1

REFERENCE="resources/reference/mini-test-genome.fna"

mkdir -p vcf/mk_dp0_as_missing

bcftools +setGT vcf/unfilt_genotypes_HC/${vcf}_HC_genotypes_unfiltered.vcf.gz -- -t q -n . -i 'FMT/DP=0 | (FMT/PL[:0]=0 & FMT/PL[:1]=0 & FMT/PL[:2]=0)' | bcftools +fill-tags - -- -t 'NMISS=N_MISSING' | bcftools view -Oz - > vcf/mk_dp0_as_missing/${vcf}_HC_genotypes_unfiltered.mrkmiss.vcf.gz

bcftools index -t vcf/mk_dp0_as_missing/${vcf}_HC_genotypes_unfiltered.mrkmiss.vcf.gz