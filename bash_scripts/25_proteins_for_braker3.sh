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

cd /scratch4/workspace/jillashey_uri_edu-Ptua_genome/protein_seqs

wget http://pdam.reefgenomics.org/download/pdam_proteins.fasta.gz
wget http://pver.reefgenomics.org/download/Pver_proteins_names_v1.0.faa.gz
wget http://cyanophora.rutgers.edu/Pocillopora_acuta/Pocillopora_acuta_HIv2.genes.pep.faa.gz
wget http://cyanophora.rutgers.edu/Pocillopora_meandrina/Pocillopora_meandrina_HIv1.genes.pep.faa.gz
wget https://bioinf.uni-greifswald.de/bioinf/partitioned_odb12/Metazoa.fa.gz

echo "unzipping and catting protein files for braker" $(date)

gunzip * 

# Cat together 
cat pdam_proteins.fasta Pver_proteins_names_v1.0.faa Pocillopora_acuta_HIv2.genes.pep.faa Pocillopora_meandrina_HIv1.genes.pep.faa Metazoa.fa > raw_proteins_for_braker.fa

# Strip out trailing stop codons (*)
sed 's/\*$//g' raw_proteins_for_braker.fa > final_proteins_for_braker.fa

echo "Complete" $(date)
