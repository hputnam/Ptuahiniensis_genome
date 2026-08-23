#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 --ntasks-per-node=1
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=100GB
#SBATCH -t 47:00:00
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

echo "Installing braker3 and dependencies" $(date)

module load apptainer/latest

# Set your custom cache/tmp dirs to avoid permission errors
export APPTAINER_CACHEDIR=/scratch4/workspace/jillashey_uri_edu-Ptua_genome/.apptainer_cache
export APPTAINER_TMPDIR=/scratch4/workspace/jillashey_uri_edu-Ptua_genome/.apptainer_cache

# Create the directory if it doesn't exist
mkdir -p $APPTAINER_CACHEDIR

# Pull the image
apptainer pull /scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3.sif docker://teambraker/braker3:latest
