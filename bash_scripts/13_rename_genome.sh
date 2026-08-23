#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1        
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=50GB                
#SBATCH -t 12:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked

# Define your file variables
OLD_GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/Ptua_cleaned.fasta"
NEW_GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/Pocillopora_tuahiniensis_genome_v1.0.fasta"
MAP_FILE="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/scaffold_name_map.txt"

# Run AWK to rename the headers and generate the mapping file simultaneously
awk '
BEGIN { count = 1 } 
/^>/ { 
    old_name = substr($1, 2); 
    new_name = "Pocillopora_tuahiniensis_scaffold" count; 
    print old_name "\t" new_name > "'"$MAP_FILE"'"; 
    print ">" new_name; 
    count++; 
    next 
} 
{ print }
' "$OLD_GENOME" > "$NEW_GENOME"
