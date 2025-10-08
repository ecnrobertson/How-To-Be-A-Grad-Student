#!/bin/bash
#SBATCH --job-name=BWA_Dup
#SBATCH --output=BWA-Dup.%j.out
#SBATCH --error=BWA_Dup.%j.err
#################
#SBATCH -t 1:00:00
#SBATCH --partition=amilan
#SBATCH --qos=normal
#SBATCH --ntasks-per-node 4
#SBATCH --mem=16G
#################
#SBATCH --mail-type=END
#SBATCH  --mail-user=youremailhere@colostate.edu
##################
#echo commands to stdout
set -x

#from within trim_merge
#for sample in `ls *1.trimmed.fastq | cut -f1 -d'_'`; do echo $sample; sbatch ../02.map_rmdup.sbatch $sample; done

source ~/.bashrc
conda activate bioinf

sample=$1

#1. Set up sample name and environment
##Plate number and directory for bamUtil. Note, plate is the order the plate was sequenced. 
PLATE="Plate1"
sample=$1
lane=L7
ID="$PLATE.$sample"
REFERENCE="../resources/reference/mini-test-genome.fna"

#make the output directory
mkdir -p ../bwa_mem
OUT="../bwa_mem"

#2. Align reads to reference genome
##Align each sample to genome. This is mapping.
bwa mem  -t 4 $REFERENCE "$sample"_1.trimmed.fastq  \
	"$sample"_2.trimmed.fastq > $OUT/aln_"$sample".sam 2> $OUT/aln_"$sample".error 

#move into the output folder
cd ../bwa_mem

#3. Convert and sort alignments
##sort the .bam file
samtools sort -o aln_"$sample".bam aln_"$sample".sam

#4. Add read group information (metadata)
##adjust the RGPL based on what you're actually using
picard AddOrReplaceReadGroups INPUT=aln_"$sample".bam RGID="$ID" RGLB="$PLATE" RGPL=illumina.HGLGKDSX7 RGPU="$PLATE"."$sample" \
RGSM="$sample" OUTPUT="$sample"_RG.bam VALIDATION_STRINGENCY=SILENT

#removing extra files to save space
rm aln_"$sample".*

#5. Remove PCR duplicates
##sort by name, not position (-n)
samtools sort -n -o "$sample"_namesort.bam "$sample"_RG.bam

##Add mate score tags for samtools markdup to select best reads
samtools fixmate -m "$sample"_namesort.bam "$sample"_fixm.bam
rm "$sample"_namesort.bam
rm "$sample"_RG.bam

##Sort again by position
samtools sort -o "$sample"_fixm.sort.bam  "$sample"_fixm.bam
rm "$sample"_fixm.bam

##Markdups
samtools markdup "$sample"_fixm.sort.bam "$sample"_mkdup.RG.bam
samtools index "$sample"_mkdup.RG.bam