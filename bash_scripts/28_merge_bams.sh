#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=100GB                
#SBATCH -t 48:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

module purge

# Load modules
module load uri/main
module load all/SAMtools/1.18-GCC-12.3.0

BAM_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/rna_bams"
# Move into the fastq directory to easily process files
cd ${BAM_DIR}

echo "Merge bam files" $(date)
samtools merge Ptua_RNAseqAll.bam *sorted.bam 

echo "Merge complete" $(date)
