#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=150GB                
#SBATCH -t 48:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Starting BRAKER3 Stranded UTR Annotation Pipeline at:" $(date)

#module load apptainer/latest

# Load modules
#module load uri/main
#module load all/SAMtools/1.18-GCC-12.3.0

#BAM_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/rna_bams"
# Move into the fastq directory to easily process files
#cd ${BAM_DIR}

#echo "Merge bam files" $(date)
#samtools merge Ptua_RNAseqAll.bam *sorted.bam 

#echo "Merge complete" $(date)

module purge
module load apptainer/latest


# ----------------------------------------------------
# Define Input and Output Paths
# ----------------------------------------------------
GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Pocillopora_tuahiniensis_genome_v1.0.fasta.masked"
PROTEINS="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/protein_seqs/final_proteins_for_braker.fa"
OUT_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output"
SIF_IMAGE="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3.sif"

# Your newly merged master BAM file
BAM_FILE="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/rna_bams/Ptua_RNAseqAll.bam"

# ----------------------------------------------------
# Setup Augustus Writeable Configuration Space
# ----------------------------------------------------
MY_AUG_CONFIG="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/augustus_config"
if [ ! -d "$MY_AUG_CONFIG" ]; then
    apptainer exec ${SIF_IMAGE} cp -r /opt/Augustus/config "$MY_AUG_CONFIG"
    chmod -R 755 "$MY_AUG_CONFIG"
fi

export AUGUSTUS_CONFIG_PATH="$MY_AUG_CONFIG"
#export JAVA_PATH="/usr/bin"
export APPTAINER_CACHEDIR=/scratch4/workspace/jillashey_uri_edu-Ptua_genome/.apptainer_cache
export APPTAINER_TMPDIR=/scratch4/workspace/jillashey_uri_edu-Ptua_genome/.apptainer_cache

# Wiping previous outputs to ensure fresh model training
rm -rf ${OUT_DIR}
mkdir -p ${OUT_DIR}

# ----------------------------------------------------
# Run BRAKER3 with Full UTR Training
# ----------------------------------------------------
apptainer exec -B /work,/scratch4,${MY_AUG_CONFIG}:/opt/Augustus/config ${SIF_IMAGE} \
    braker.pl \
    --genome=${GENOME} \
    --bam=${BAM_FILE} \
    --prot_seq=${PROTEINS} \
    --workingdir=${OUT_DIR} \
    --threads=${SLURM_CPUS_PER_TASK} \
    --AUGUSTUS_CONFIG_PATH=${MY_AUG_CONFIG} \
   # --JAVA_PATH=${JAVA_PATH} \
    --species=Pocillopora_tuahiniensis \
    --gff3

echo "BRAKER3 pipeline completed at:" $(date)
