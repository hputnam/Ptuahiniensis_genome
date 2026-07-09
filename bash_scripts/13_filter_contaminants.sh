#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 --ntasks-per-node=2
#SBATCH --partition=uri-cpu
#SBATCH --no-requeue
#SBATCH --mem=100GB
#SBATCH -t 100:00:00
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

module load uri/main
module load seqtk/1.4-GCC-12.3.0

echo "Make list of all reads and remove contam reads" $(date)
grep "^>" Ptua_hifi_reads.fasta | sed 's/^>//' > Ptua_fasta_reads.txt
grep -v -F -f reads_to_remove.txt Ptua_fasta_reads.txt > filtered_reads.txt

echo "Filtering hifi reads that passed contamination filtering" $(date)

cd /work/pi_hputnam_uri_edu/Ptua_genome

seqtk subseq -v Ptua_hifi_reads.fasta filtered_reads.txt > Ptua_hiti_filtered_reads.fasta

grep -c ">" Ptua_hifi_reads.fasta
grep -c ">" Ptua_hiti_filtered_reads.fasta

echo "Filtering complete!" $(date)
