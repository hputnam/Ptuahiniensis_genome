#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 --ntasks-per-node=2
#SBATCH --partition=uri-cpu
#SBATCH --no-requeue
#SBATCH --mem=100GB
#SBATCH -t 24:00:00
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

cd /work/pi_hputnam_uri_edu/Ptua_genome

module load uri/main
module load BLAST+/2.15.0-gompi-2023a

echo "Make BLAST db of euk contam seqs" $(date)

makeblastdb -in contam_screen/contam_in_euks.fa -dbtype nucl -out contam_screen/contam_euk_db

echo "BLAST hifi reads against euk contam seqs" $(date)

blastn \
  -query Ptua_hifi_reads.fasta \
  -db contam_screen/contam_euk_db \
  -out euk_contaminant_hits_rr.txt \
  -outfmt "6 qseqid sseqid evalue bitscore" \
  -evalue 1e-4

echo "BLAST to euk contam seqs complete" $(date)
