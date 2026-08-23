#!/usr/bin/env bash
#SBATCH --job-name=fcs_gx_screen
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --partition=uri-gpu
#SBATCH --gres=gpu:1
#SBATCH --mem=500GB
#SBATCH -t 24:00:00
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

# Load Apptainer module
module load apptainer/latest 
module load conda/latest

# Go to location 
cd /scratch4/workspace/jillashey_uri_edu-Ptua_genome

# Environment Setup
export PATH="/work/pi_hputnam_uri_edu/conda/tools/fcs_gx:$PATH"
export FCS_DEFAULT_IMAGE="/work/pi_hputnam_uri_edu/conda/tools/fcs_gx/fcs-gx.sif"
export NCBI_FCS_REPORT_ANALYTICS=0

# Path Variables
LOCAL_DB="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/fcs_gx_db/gxdb"
ASSEMBLY="Ptua_primary.fasta"
OUTDIR="fcs_gx_output"
TAX_ID="3041103" # NCBI taxon ID for Ptua

echo "Starting FCS-GX Screening:" $(date)

# Run FCS-GX Screen
python3 /work/pi_hputnam_uri_edu/conda/tools/fcs_gx/fcs.py screen genome \
    --fasta "$ASSEMBLY" \
    --out-dir "$OUTDIR" \
    --gx-db "$LOCAL_DB" \
    --tax-id "$TAX_ID"

echo "FCS-GX Screening Complete:" $(date)
