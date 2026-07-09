#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 --ntasks-per-node=2
#SBATCH --partition=uri-cpu
#SBATCH --no-requeue
#SBATCH --mem=100GB
#SBATCH -t 5-00:00:00
#SBATCH -q long
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

cd /work/pi_hputnam_uri_edu/Ptua_genome

module load uri/main
module load BLAST+/2.15.0-gompi-2023a

## No need to build blast db, viral db already created 

echo "BLAST hifi reads against viral genome seqs" $(date)

blastn \
  -query Ptua_hifi_reads.fasta \
  -db /datasets/bio/ncbi-db/2025-11-16/ref_viruses_rep_genomes \
  -out viral_contaminant_hits_rr.txt \
  -outfmt "6 qseqid sseqid evalue bitscore" \
  -evalue 1e-4

echo "BLAST to viral genome seqs complete" $(date)
