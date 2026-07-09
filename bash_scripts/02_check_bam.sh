#!/bin/bash
#SBATCH --job-name=check_bam
#SBATCH --nodes=1 --cpus-per-task=8
#SBATCH --mem=250G  # Requested Memory
#SBATCH -p gpu  # Partition
#SBATCH -G 1  # Number of GPUs
#SBATCH --time=06:00:00  # Job time limit
#SBATCH -o slurm-check_bam.out  # %j = job ID
#SBATCH -e slurm-check_bam.err  # %j = job ID
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

#load modules if needed
module load samtools/1.19.2

samtools quickcheck -v /work/pi_hputnam_uri_edu/Ptua_genome/raw/m84100_251021_203206_s3.hifi_reads.bam      # sanity check
