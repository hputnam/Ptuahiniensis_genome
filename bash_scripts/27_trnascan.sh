#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=uri-cpu
#SBATCH --no-requeue
#SBATCH --mem=100GB                
#SBATCH -t 48:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Starting tRNAscan-SE Analysis at:" $(date)

module load conda/latest # need to load before making any conda envs
conda activate /work/pi_hputnam_uri_edu/conda/envs/trnascan

# Define your paths
GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Pocillopora_tuahiniensis_genome_v1.0.fasta.masked"
OUT_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/trnascan_output"

mkdir -p ${OUT_DIR}

tRNAscan-SE -E \
            --threads ${SLURM_CPUS_PER_TASK} \
            -o ${OUT_DIR}/Ptua-tRNA.out \
            -f ${OUT_DIR}/Ptua-tRNA_struct.out \
            -m ${OUT_DIR}/Ptua-tRNA_stats.out \
            -j ${OUT_DIR}/Ptua-tRNA.gff3 \
            -a ${OUT_DIR}/Ptua-tRNA.fasta \
            -d \
            ${GENOME}

conda deactivate

echo "tRNAscan analysis complete" $(date)
