#!/bin/bash
#
#SBATCH --job-name=gvcf
#SBATCH --output=gvcf.%j.out
#SBATCH --error=gvcf.%j.err
#################
#SBATCH -t 2:00:00
#SBATCH -p amilan
#SBATCH --qos=normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node 4
#SBATCH --mem=16G
#################
#SBATCH --mail-type=END
#SBATCH  --mail-user=ericacnr@colostate.edu
#################
#echo commands to stdout
set -x

source ~/.bashrc

#from inside the bwa_mem folder
##for sample in `ls *_mkdup.RG.bam|cut -f 1 -d "_"`; do echo $sample; sbatch ../04a.call_genotypes.sbatch $sample; done

sample=$1

##Location of fasta file and 
REFERENCE="resources/reference/mini-test-genome.fna"

mkdir -p ../vcf/raw_genotypes_HC
OUT="../vcf/raw_genotypes_HC"

#CONDA
conda activate gatk_4

#we need a specific reference genome dictionary
gatk CreateSequenceDictionary -R $FASTA -O ../resources/reference/mini-test-genome.dict

#if using jar file, the path is going to be specific to our you set up your conda environment
java -Djava.io.tmpdir=/scratch/alpine/ericacnr@colostate.edu/tmp -Xmx37g -jar /curc/sw/install/bio/gatk/4.3.0.0/gatk-package-4.3.0.0-local.jar HaplotypeCaller \
	-I  "$sample"_mkdup.RG.bam \
	--sample-name ${sample} \
	-R $REFERENCE \
	--emit-ref-confidence GVCF \
	-O $OUT/${sample}.raw.snps.indels.g.vcf