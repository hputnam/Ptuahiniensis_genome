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

echo "Starting barrnap Analysis at:" $(date)

module load conda/latest # need to load before making any conda envs
conda activate /work/pi_hputnam_uri_edu/conda/envs/barrnap

GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Pocillopora_tuahiniensis_genome_v1.0.fasta"
OUT_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/barrnap_output"

mkdir -p ${OUT_DIR}

barrnap --kingdom euk \
        --threads ${SLURM_CPUS_PER_TASK} \
        --outseq ${OUT_DIR}/Ptua_rRNA.fa \
        ${GENOME} > ${OUT_DIR}/Ptua_rRNA.gff3

echo "barrnap complete" $(date)
conda deactivate
