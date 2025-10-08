#!/bin/bash
#
#SBATCH --job-name=COV
#SBATCH --output=COV.%A_%a.out
#SBATCH --error=COV.%A_%a.err
#################
#SBATCH -t 1:00:00
#SBATCH --partition=amilan
#SBATCH --qos=normal
#SBATCH --ntasks-per-node 1
#SBATCH --mem=4G
#################
#SBATCH --mail-type=FAIL
#SBATCH  --mail-user=ericacnr@colostate.edu
##################
#echo commands to stdout
set -x
##################
source ~/.bashrc
conda activate bioinf

#running from the head directory 01.fastq_processing
IN="../bwa_mem"

#make the coverage directory and move into it
mkdir -p cov
cd cov

#this is going to only call a subset of the bams, so you have to go in and change this when you run the next job to move onto the next subset
for sample in `ls $IN/19*_mkdup.RG.bam` ##you don't need to choose one sample, but you do need to choose 10 or less in the ls function
do
        bedtools genomecov -d -ibam $sample > "$sample"_cov.bedtools.txt
        awk '{if($3<500) {total+=$3; ++lines}} END {print FILENAME," ",total/lines}' "$sample"_cov.bedtools.txt >> covSummary.bedtools.txt
	rm "$sample"_cov.bedtools.txt
done