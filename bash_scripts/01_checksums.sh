#!/bin/bash
#SBATCH --job-name=checksum_raw
#SBATCH --nodes=1 --cpus-per-task=8
#SBATCH --mem=250G  # Requested Memory
#SBATCH -p gpu  # Partition
#SBATCH -G 1  # Number of GPUs
#SBATCH --time=06:00:00  # Job time limit
#SBATCH -o slurm-checksum_raw.out  # %j = job ID
#SBATCH -e slurm-checksum_raw.err  # %j = job ID
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

#load modules if needed

#run checksum on raw data
md5sum /work/pi_hputnam_uri_edu/Ptua_genome/raw/*.bam* > 20251023_URI_working.md5

