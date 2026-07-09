#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=150GB                
#SBATCH -t 72:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Starting BRAKER3 Annotation Pipeline at:" $(date)

module load apptainer/latest

# ----------------------------------------------------
# Define Input and Output Paths
# ----------------------------------------------------
GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Pocillopora_tuahiniensis_genome_v1.0.fasta"
PROTEINS="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/protein_seqs/final_proteins_for_braker.fa"
OUT_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output"
SIF_IMAGE="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3.sif"

# Comma-separated BAMs list
BAM_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/rna_bams"
BAM_FILES="${BAM_DIR}/POC-201-TP1.sorted.bam,${BAM_DIR}/POC-201-TP2.sorted.bam,${BAM_DIR}/POC-201-TP3.sorted.bam,${BAM_DIR}/POC-219-TP1.sorted.bam,${BAM_DIR}/POC-219-TP2.sorted.bam,${BAM_DIR}/POC-219-TP3.sorted.bam,${BAM_DIR}/POC-219-TP4.sorted.bam,${BAM_DIR}/POC-222-TP1.sorted.bam,${BAM_DIR}/POC-222-TP2.sorted.bam,${BAM_DIR}/POC-222-TP3.sorted.bam,${BAM_DIR}/POC-222-TP4.sorted.bam,${BAM_DIR}/POC-255-TP1.sorted.bam,${BAM_DIR}/POC-255-TP2.sorted.bam,${BAM_DIR}/POC-255-TP3.sorted.bam,${BAM_DIR}/POC-255-TP4.sorted.bam,${BAM_DIR}/POC-259-TP1.sorted.bam,${BAM_DIR}/POC-259-TP2.sorted.bam,${BAM_DIR}/POC-259-TP3.sorted.bam,${BAM_DIR}/POC-259-TP4.sorted.bam,${BAM_DIR}/POC-40-TP1.sorted.bam,${BAM_DIR}/POC-40-TP2.sorted.bam,${BAM_DIR}/POC-40-TP3.sorted.bam,${BAM_DIR}/POC-40-TP4.sorted.bam,${BAM_DIR}/POC-42-TP1.sorted.bam,${BAM_DIR}/POC-42-TP2.sorted.bam,${BAM_DIR}/POC-42-TP3.sorted.bam,${BAM_DIR}/POC-42-TP4.sorted.bam,${BAM_DIR}/POC-52-TP1.sorted.bam,${BAM_DIR}/POC-52-TP2.sorted.bam,${BAM_DIR}/POC-52-TP3.sorted.bam,${BAM_DIR}/POC-52-TP4.sorted.bam,${BAM_DIR}/POC-53-TP1.sorted.bam,${BAM_DIR}/POC-53-TP2.sorted.bam,${BAM_DIR}/POC-53-TP3.sorted.bam,${BAM_DIR}/POC-53-TP4.sorted.bam,${BAM_DIR}/POC-57-TP1.sorted.bam,${BAM_DIR}/POC-57-TP2.sorted.bam,${BAM_DIR}/POC-57-TP3.sorted.bam,${BAM_DIR}/POC-57-TP4.sorted.bam"

# ----------------------------------------------------
# FIX: Extract and isolate Augustus Config onto Scratch
# ----------------------------------------------------
MY_AUG_CONFIG="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/augustus_config"

if [ ! -d "$MY_AUG_CONFIG" ]; then
    echo "Extracting Augustus config directory from container..."
    # Throws the config directory from inside the image to your writable scratch space
    apptainer exec ${SIF_IMAGE} cp -r /opt/Augustus/config "$MY_AUG_CONFIG"
    chmod -R 755 "$MY_AUG_CONFIG"
fi

# Export environment variable for the container to register
export AUGUSTUS_CONFIG_PATH="$MY_AUG_CONFIG"

# Set up Apptainer Cache
export APPTAINER_CACHEDIR=/scratch4/workspace/jillashey_uri_edu-Ptua_genome/.apptainer_cache
export APPTAINER_TMPDIR=/scratch4/workspace/jillashey_uri_edu-Ptua_genome/.apptainer_cache
mkdir -p $APPTAINER_CACHEDIR

# ----------------------------------------------------
# Run BRAKER3
# ----------------------------------------------------
# Added --AUGUSTUS_CONFIG_PATH flag to explicitly force the pipeline to use your scratch copy
apptainer exec -B /work,/scratch4,${MY_AUG_CONFIG}:/opt/Augustus/config ${SIF_IMAGE} \
    braker.pl \
    --genome=${GENOME} \
    --bam=${BAM_FILES} \
    --prot_seq=${PROTEINS} \
    --workingdir=${OUT_DIR} \
    --threads=${SLURM_CPUS_PER_TASK} \
    --AUGUSTUS_CONFIG_PATH=${MY_AUG_CONFIG} \
    --gff3

echo "BRAKER3 pipeline completed at:" $(date)
