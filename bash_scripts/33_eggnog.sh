#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12         
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=50GB                
#SBATCH -t 48:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Starting EggNOG-mapper analysis at:" $(date)

# Load environmental modules
module load uri/main
module load all/eggnog-mapper/2.1.9-foss-2022a

# Define Paths
PROT_FASTA="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/braker.aa"
OUT_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/func_anno"

# Run EggNOG-mapper using ultra-fast diamond mode
emapper.py \
    -i ${PROT_FASTA} \
    -o ${OUT_DIR}/Ptua_eggnog \
    --data_dir /datasets/bio/eggnog5-data/ \
    -m diamond \
    --sensmode sensitive \
    --cpu ${SLURM_CPUS_PER_TASK} \
    --override

echo "EggNOG-mapper analysis completed at:" $(date)
