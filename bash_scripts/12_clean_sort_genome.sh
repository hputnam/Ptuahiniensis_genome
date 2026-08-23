#!/usr/bin/env bash
#SBATCH --export=ALL
#SBATCH --ntasks=1 --cpus-per-task=24
#SBATCH --partition=uri-cpu,cpu,cpu-preempt
#SBATCH --no-requeue
#SBATCH --mem=200GB
#SBATCH -t 24:00:00
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

module load conda/latest
conda activate /work/pi_hputnam_uri_edu/conda/envs/funannotate

echo "Remove duplicates and short contigs" $(date)

funannotate clean -i Ptua_polished.fasta -o Ptua_cleaned.fasta --exhaustive -m 200

echo "Cleaning complete, rename contigs" $(date)

funannotate sort -i Ptua_cleaned.fasta -o Ptua_cleaned_renamed.fasta -b Pocillopora_tuahiniensis

echo "Renaming complete" $(date)

grep -c ">" Ptua_polished.fasta
grep -c ">" Ptua_cleaned.fasta
grep -c ">" Ptua_cleaned_renamed.fasta

conda deactivate
