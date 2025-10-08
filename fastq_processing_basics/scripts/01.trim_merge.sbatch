#!/bin/bash
#SBATCH --job-name=TRIM_MERGE
#SBATCH --output=TRIM_MERGE.%j.out
#SBATCH --error=TRIM_MERGE.%j.err
#################
#SBATCH -t 1:00:00
#SBATCH --partition=amilan
#SBATCH --qos=normal
#SBATCH --ntasks-per-node 4
#SBATCH --mem=12G
#################
#SBATCH --mail-type=END
#################
#SBATCH  --mail-user=youremailhere@colostate.edu
##################
#echo commands to stdout
set -x

##################
#here's how you'll run the script. I note that it's from a for loop so I don't forget, and then note the directory where it'll work from given the directory structure I've chosen, then I provide the for loop that I copy and paste into the terminal to submit the job.
#run sbatch in for loop
#from within raw_data
#T"$sample"_T2087_HY75HDSX2_L001_R1_001.fastq.gz
#for sample in `ls *R1*.fastq.gz |cut -f1 -d '_'|sed 's/T//g'`; do echo  $sample; sbatch ../01.trim_merge.sbatch $sample ; done

#here I'm waking up the conda environment where I've installed trimmomatic
source ~/.bashrc
conda activate bioinf

#this is grabbing the sample information that you provided with the for loop
sample=$1

#make the output directory, this will only make it if it doesn't already exist
mkdir -p ../trim_merge
#set the out path to this directory
OUT="../trim_merge"
ADAPTER="/scratch/alpine/ericacnr@colostate.edu/HTBAGS-Test/fastq_processing_test/01.fastq_processing/resources/adapters/TruSeq3-PE-2.fa"

#here's you trimmomatic function
#first you start by giving it the input files. the "$sample" will be replaces with the variable value. Replace this to match your file names.
#then we're gonna give it the output files names we want, one for both the R1 and the R2 reads
#then give it information on what adapters to looks for. I think there are defaults for this but you can also download and provide the adaptor sequences directly, as I've done here.
#then some parameters for how it will identify and trim things
trimmomatic PE -threads 4 T"$sample"_T2087_HY75HDSX2_L001_R1_001.fastq.gz T"$sample"_T2087_HY75HDSX2_L001_R2_001.fastq.gz  \
  $OUT/"$sample"_1.trimmed.fastq $OUT/"$sample"_1un.trimmed.fastq \
  $OUT/"$sample"_2.trimmed.fastq $OUT/"$sample"_2un.trimmed.fastq \
  ILLUMINACLIP:"$ADAPTER":2:30:10 \
  SLIDINGWINDOW:4:20 LEADING:3 TRAILING:3 MINLEN:36