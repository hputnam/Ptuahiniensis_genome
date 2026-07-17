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

echo "Cat GFFs" $(date)

cat braker3_output/braker.gff3 \
    trnascan_output/Ptua-tRNA.gff3 \
    barrnap_output/Ptua_rRNA.gff3 \
    > Pocillopora_tuahiniensis_genome_v1.0.master.gff3
    
echo "Cat complete" $(date)
