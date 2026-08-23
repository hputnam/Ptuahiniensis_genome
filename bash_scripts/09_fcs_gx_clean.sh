#!/usr/bin/env bash
#SBATCH --export=ALL
#SBATCH --ntasks=1 --cpus-per-task=24
#SBATCH --partition=uri-cpu
#SBATCH --no-requeue
#SBATCH --mem=100GB
#SBATCH -t 24:00:00
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

# Load modules 
module load uri/main
module load seqtk/1.4-GCC-12.3.0

# Go to location 
cd /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Starting FCS-GX Cleaning:" $(date)

# Extract non-comment sequence IDs into a list of contigs to remove
grep -v "^#" fcs_gx_output/Ptua_primary.3041103.fcs_gx_report.txt | awk '{print $1}' | sort -u > contigs_to_remove.txt

# Make a list of all reads 
grep "^>" Ptua_primary.fasta | sed 's/^>//' > Ptua_primary.txt

# Make a list of filtered reads only 
grep -v -F -f contigs_to_remove.txt Ptua_primary.txt > filtered_contigs.txt

# Filter reads 
seqtk subseq -v Ptua_primary.fasta filtered_contigs.txt > Ptua_primary_clean.fasta

grep -c ">" Ptua_primary.fasta
grep -c ">" Ptua_primary_clean.fasta

echo "FCS-GX Cleaning Complete:" $(date)
