#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 --ntasks-per-node=1
#SBATCH --partition=uri-cpu
#SBATCH --no-requeue
#SBATCH --mem=25GB
#SBATCH -t 24:00:00
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

cd /scratch4/workspace/jillashey_uri_edu-Ptua_genome/rna_fastq

wget --mirror --page-requisites --no-parent --no-host-directories --cut-dirs=5 \
     --accept "fastq.gz,fastq,fq.gz,fq" \
     https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/01.00-F-Ptua-RNAseq-trimming-fastp-FastQC-MultiQC/
