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

# load modules needed
module purge 

# Load modules
module load uri/main
module load all/HISAT2/2.2.1-gompi-2022a
module load all/SAMtools/1.18-GCC-12.3.0

GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Pocillopora_tuahiniensis_genome_v1.0.fasta"
INDEX="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Ptua_ref"
FASTQ_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/rna_fastq"
BAM_OUT_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/rna_bams"

# Ensure output directory exists
mkdir -p ${BAM_OUT_DIR}

echo "Building genome reference:" $(date)
# Build HISAT2 index using your variables
hisat2-build -f ${GENOME} ${INDEX}
echo "Reference genome indexed. Starting alignment:" $(date)

# Move into the fastq directory to easily process files
cd ${FASTQ_DIR}

# Loop through all Forward (R1) files
for r1_file in *_R1_*.fq.gz; do
    sample_name=$(echo "${r1_file}" | awk -F "_R1_" '{print $1}')
    r2_file=$(echo "${r1_file}" | sed 's/_R1_/_R2_/')
    echo "Processing sample: ${sample_name} at $(date)"
    hisat2 -p 24 \
           --dta \
           -x ${INDEX} \
           -1 ${r1_file} \
           -2 ${r2_file} \
           --summary-file ${BAM_OUT_DIR}/${sample_name}_align_stats.txt \
           -S ${BAM_OUT_DIR}/${sample_name}.sam
    echo "Sorting and converting ${sample_name} to BAM..."
    samtools sort -@ 24 \
                  -o ${BAM_OUT_DIR}/${sample_name}.sorted.bam \
                  ${BAM_OUT_DIR}/${sample_name}.sam
    samtools index ${BAM_OUT_DIR}/${sample_name}.sorted.bam
    rm ${BAM_OUT_DIR}/${sample_name}.sam
    echo "Sample ${sample_name} alignment complete!"
    echo "----------------------------------------"
done

echo "All alignments complete at:" $(date)
