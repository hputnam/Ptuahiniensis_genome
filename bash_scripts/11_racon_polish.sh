#!/usr/bin/env bash
#SBATCH --export=ALL
#SBATCH --ntasks=1 --cpus-per-task=24
#SBATCH --partition=uri-cpu,cpu,cpu-preempt
#SBATCH --no-requeue
#SBATCH --mem=200GB
#SBATCH -t 24:00:00
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

# Load modules 
module load uri/main 
module load all/Racon/1.5.0-GCCcore-12.3.0 
module load all/minimap2/2.26-GCCcore-12.3.0

echo "Aligning raw reads to scaffolded assembly" $(date)
minimap2 -x map-hifi -t 36 \
    Ptua_primary_clean.fasta.k32.w100.z1000.ntLink.gap_fill.5rounds.fa \
    /work/pi_hputnam_uri_edu/Ptua_genome/Ptua_hifi_reads.fastq.gz \
    > ptua_ntlink_mapped.paf

echo "Alignment complete, polish" $(date)

# Polish filled gap regions
racon -t 36 \
    /work/pi_hputnam_uri_edu/Ptua_genome/Ptua_hifi_reads.fastq.gz \
    ptua_ntlink_mapped.paf \
    Ptua_primary_clean.fasta.k32.w100.z1000.ntLink.gap_fill.5rounds.fa \
    > Ptua_polished.fasta

echo "Polishing complete!" $(date)

rm ptua_ntlink_mapped.paf
