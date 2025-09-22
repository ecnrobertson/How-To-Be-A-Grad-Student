---
title: "Basic_Fastq_Processing"
author: "Erica Robertson"
date: "2025-08-16"
output: html_document
---

# INTRODUCTION
So this will be a walk through of a pipeline for processing sequence data. This is a very basic pipline that should work with most WGS sequence data. These scripts are adapted and streamlined from scripts that Christen Bossu wrote and shared with me during my second year of my PhD.

## Setting the stage
So, each of these scripts is numbered based on the order in which they are run. These are all designed to be run on the cluster. I also assume that you have a conda environment set up with all these programs. Although on clusters like alpine you have the option of using built in modules, these are often limited and it's a better habit to use conda or mamba environments anyway. My conda environment for all these programs is called bioinf, so you'll see me activating that at the beginning of each script. Additionally, each script includes the necessary SBATCH information so that it can be submitted and run correctly. I will include time and memory details, but take these with a grain of salt. Often, I've requested much more than I need. This is partly because I didn't know better (and didn't adjust once learning what the job actually needed) and partly because it sucks when a job times out or fails from lack of memory. Requesting more resources often means the job will take longer to start, so there's pros and cons. Fiddle with these as needed!

### notes on submitting jobs
Another thing to note is that, a lot of the time, I'm running this batch from for loop instead of a direct sbatch command. So, for this, you would be within the folder that has the input data. You would then run a command similar to this:

```{bash}
for sample in `ls *1.fq.gz |cut -f1 -d '_'|sed 's/Z//g'`; do echo  $sample; sbatch ../../1.trim.sbatch $sample ; done
```

Let's break this down. This is basically saying that *for* "sample" (which is the variable name), *in* (assigns the values to the sample variable), do this function (in this case, submit it as a job).

`ls *1.fq.gz |cut -f1 -d '_'|sed 's/Z//g'`
This part takes the list of file names, in this case they look something like this Zsample_1.fq.gz and pipe that into a cut function that takes everything before the first (-f1) underscore ('_') (which leaves us with the Zsample part) and pipe that into a sed function that removes the Z. What you're left with is just the sample number, and that's going to get input as the variable name when you submit the sbatch script ../../1.trim.sbatch or whatever it is. 

The "do echo  $sample" is just so it reads out the sample names to the screen which allows you to verify it's working properly. A good idea is to test just that part of the script to make sure it's working before submitting a million jobs which the wrong variable name.

You'll see in the scripts that follow that one of the first things I write is sample=$1, which basically assigned the variable sample to whatever input that for loop generated when running the job.

Another option for submitting jobs is through an array. <insert details here>

## File Structure
The file structure is going to be different for you, probably, but the file structure I use goes like this.

<pre>
Project Directory
|- *analysis*
  |-*01.fastq_processing*
    |-01.trim_merge.sbatch
    |-02.map_rmdup.sbatch
    |-03.coverage.sbatch
    |-04.call_genotypes.sbatch
    |-05.filtering.sbatch
    |-*raw_data*
      |-{sample}_R1.fastq
      |-{sample}_R2.fastq
    |-*trim_merge*
      |-{sample}.merged.fq.gz
    |-*bwa_mem*
      |-{sample}_rmdup.bam
    |-*vcf*
      |-{sample}.vcf
</pre>

## Steps and Overview
1.trim_merge.sbatch
The goal of this step is to trim off adapter sequences and merged the R1 and R2 reads together. The trimming of adaptors is going to be specific to the sequencing platform you used. The R1 and R2 is a product of paired end sequencing. There are multiple different programs that can do this. Originally, I learned with trimmomatic. This works well but is a little slow. Another option in FastP, which, as it's named, it faster. SeqPrep is another option. There are pros and cons for every program, and some programs are better suited to some types of data, so do a little research to figure out what the best option is. For this, we'll use trimmomatic.

2.map_rmdup.sbatch
For this step we'll use BWA. Here we're aligning out sequence reads to a reference genome. The more closely related (and the better quality) the reference is the better the mapping will go. Additionally, more fragmented sequence data (e.g. historical DNA) will have a harder time mapping. Also in this step you will identify and remove PCR duplicates with samtools. These are products of the sequencing process that biases your coverage information. The final major thing here is assigning read groups with picard. <insert information on read groups here>. Throughout this process there's indexing and deleting of unnecessary intermediate files so they don't clog up your storage.

3.coverage.sbatch
This is a simple script that estimates the coverage for each sample. You'll run this is batches as it computationally intensive. This is a super important step as you'll use this information to decide if you need to down-sample. Down-sampling is included as bonus at the end.

4.call_genotypes.sbatch
Wow, we're finally there! Let's call genotypes. We're going to do this with GATK, because I'm assuming you have decent coverage (another reason to do the coverage script before this one). If you have low quality or low coverage, you'll want to use ANGST. <There's a whole thing about called genotypes versus genotype likelihoods, which I might discuss later but you can also just read a paper about it.>

5.filtering.sbatch
Ah, filtering. Arguably the hardest part. For every other step there are generally pretty well established guidlines for the parameters, and often the defaults work pretty well for a typical data set. Filtering though is an art. I'm including the parameters here that I used, but that was before I was informed on the complex issues involved. What kind of data you have and what you're going to do with said data matters a lot. Will wrote an excellent paper that helps break this down! <link here>

# THE PROCESS
For all of these steps, I'll put the scripts in and annotate them with details about each part. The first part of the script contains the SBATCH details, which I'm not going to explain here as I think it'll be a separate thing. Within the main part of the script I'll # in some notes.
## Getting the sequence data
<wget>
<OVIS file transfer>

## Trimming and Merging
```{bash, label="01.trim_merge.sbatch"}
#!/bin/bash
#SBATCH --job-name=TRIM_MERGE
#SBATCH --output=TRIM_MERGE.%j.out
#SBATCH --error=TRIM_MERGE.%j.err
#################
#SBATCH -t 6:00:00
#SBATCH --partition=amilan
#SBATCH --qos=normal
#SBATCH --ntasks-per-node 4
#SBATCH --mem=12G
#################
#SBATCH --mail-type=END
#################
#SBATCH  --mail-user=ericacnr@colostate.edu
##################
#echo commands to stdout
set -x

##################
#here's how you'll run the script. I note that it's from a for loop so I don't forget, and then note the directory where it'll work from given the directory structure I've chosen, then I provide the for loop that I copy and paste into the terminal to submit the job.
#run sbatch in for loop
#from within raw_data
#for sample in `ls *1.fq.gz |cut -f1 -d '_'|sed 's/Z//g'`; do echo  $sample; sbatch ../01.trim_merge.sbatch $sample ; done

#here I'm waking up the conda environment where I've installed trimmomatic
source ~/.bashrc
conda activate bioinf

#this is grabbing the sample information that you provided with the for loop
sample=$1

#here's you trimmomatic function
#first you start by giving it the input files. the "$sample" will be replaces with the variable value. Replace this to match your file names.
trimmomatic PE -threads 4 Z"$sample"_CK...fq Z"$sample"_CK..._fq  \
#then we're gonna give it the output files names we want, one for both the R1 and the R2 reads
  "$sample"_1.trimmed.fastq "$sample"_1un.trimmed.fastq \
  "$sample"_2.trimmed.fastq "$sample"_2un.trimmed.fastq \
#this gives it information on what adaptors to looks for. I think there are defaults for this but you can also download and provide the adaptor sequences directly, as I've done here.
  ILLUMINACLIP:../../resources/adapters/TruSeq3-PE-2.fa:2:30:10 \
#then some parameters for how it will identify and trim things
  SLIDINGWINDOW:4:20 LEADING:3 TRAILING:3 MINLEN:36
```

## Mapping and Removing Duplicates
## Coverage
## Calling Genotypes
## Filtering
