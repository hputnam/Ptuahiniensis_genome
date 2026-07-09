#!/bin/bash
#SBATCH --job-name=convert_fastq_fasta
#SBATCH --nodes=1 --cpus-per-task=8
#SBATCH --mem=250G  # Requested Memory
#SBATCH -p gpu  # Partition
#SBATCH -G 1  # Number of GPUs
#SBATCH --time=06:00:00  # Job time limit
#SBATCH -o slurm-convert_fastq_fasta.out  # %j = job ID
#SBATCH -e slurm-convert_fastq_fasta.err  # %j = job ID
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

#load modules if needed
module load conda/latest 
conda activate pbtk
conda install -y -c bioconda -c conda-forge seqtk

echo "Convert PacBio fastq file to fasta file" $(date)

seqtk seq -A Ptua_hifi_reads.fastq.gz > Ptua_hifi_reads.fasta

echo "Fastq to fasta complete! Summarize read lengths" $(date)

awk '/^>/ { if (seq) {print header"\t"length(seq)}; header=substr($0,2); seq="" ; next } 
     {seq=seq$0} 
     END {print header"\t"length(seq)}' Ptua_hifi_reads.fasta > Ptua_rr_read_lengths.txt

echo "Read length summary complete" $(date)

