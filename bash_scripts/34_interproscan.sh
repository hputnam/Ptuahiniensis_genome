#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=100GB                
#SBATCH -t 120:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Starting InterProScan analysis at:" $(date)

# Load modules
module load uri/main
module load all/InterProScan/5.73-104.0-foss-2024a

# Remove asterisks 
sed 's/\*//g' /scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/braker.aa > /scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/braker_clean.aa

# Define paths
PROT_FASTA="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/braker_clean.aa"
OUT_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/func_anno"

#mkdir -p ${OUT_DIR}

# Run interproscan
interproscan.sh \
    -i ${PROT_FASTA} \
    -b ${OUT_DIR}/Ptua_iprscan \
    -f XML \
    -goterms \
    -pa \
    -cpu ${SLURM_CPUS_PER_TASK}

echo "InterProScan analysis completed at:" $(date)
