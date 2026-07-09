#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 --ntasks-per-node=1
#SBATCH --partition=uri-cpu
#SBATCH --no-requeue
#SBATCH --mem=50GB
#SBATCH -t 24:00:00
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

cd /work/pi_hputnam_uri_edu/Ptua_genome

echo "Filter euk seqs for bit score >1000" $(date)

awk '$NF > 1000' euk_contaminant_hits_rr.txt > euk_contaminant_hits_rr_bit1000.txt
wc -l euk_contaminant_hits_rr_bit1000.txt
rm euk_contaminant_hits_rr.txt

echo "Filter prok seqs for bit score >1000" $(date)
awk '$NF > 1000' prok_contaminant_hits_rr.txt > prok_contaminant_hits_rr_bit1000.txt
wc -l prok_contaminant_hits_rr_bit1000.txt
rm prok_contaminant_hits_rr.txt

echo "Filter sym seqs for bit score >1000" $(date)
awk '$NF > 1000' sym_contaminant_hits_rr.txt > sym_contaminant_hits_rr_bit1000.txt
wc -l sym_contaminant_hits_rr_bit1000.txt
rm sym_contaminant_hits_rr.txt
