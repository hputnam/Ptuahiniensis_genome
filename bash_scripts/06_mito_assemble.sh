#!/bin/bash
#SBATCH --job-name=mito_assemble
#SBATCH --nodes=1 --cpus-per-task=8
#SBATCH --mem=250G  # Requested Memory
#SBATCH -p gpu  # Partition
#SBATCH -G 1  # Number of GPUs
#SBATCH --time=12:00:00  # Job time limit
#SBATCH -o slurm-mito_assemble.out  # %j = job ID
#SBATCH -e slurm-mito_assemble.err  # %j = job ID
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

echo "Starting mito assembly with Pocillopora refs" $(date)

#load modules if needed
module load conda/latest
conda create -n mitohifi -y -c bioconda -c conda-forge mitohifi 
conda activate mitohifi

cd /work/pi_hputnam_uri_edu/Ptua_genome

singularity exec --bind /work/pi_hputnam_uri_edu/Ptua_genome/ docker://ghcr.io/marcelauliano/mitohifi:master mitohifi.py -r Ptua_hiti_filtered_reads.fasta \
 -f EF526302.1.fasta -g EF526302.1.gb \
 -t 8 \
 -o 5 #invert code 

echo "Mito assembly complete!" $(date)
