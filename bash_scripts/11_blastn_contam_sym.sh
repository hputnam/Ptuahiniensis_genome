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

echo "Concatenate sym genomes for BLAST " $(date)
cat /work/pi_hputnam_uri_edu/Symbiont_Genomes/C_goreaui_cladeC1/SymbC1.Genome.Scaffolds.fasta /work/pi_hputnam_uri_edu/Symbiont_Genomes/Durusdinium_sp/102_symbd_genome_scaffold.fa /work/pi_hputnam_uri_edu/Symbiont_Genomes/Cladocopium_goreaui_SCF055/Cladocopium_goreaui/Cladocopium_goreaui.genome.fa /work/pi_hputnam_uri_edu/Symbiont_Genomes/Symbiodinium_CladeC/symC_scaffold_40.fasta /work/pi_hputnam_uri_edu/Symbiont_Genomes/Cladocopium_sp_C15/SymbC15_plutea_v2.1.fna /work/pi_hputnam_uri_edu/Symbiont_Genomes/Cladocopium_sp_C92/Cladocopium_sp_C92/Cladocopium_sp_C92.genome.fa > ptua_sym_genomes_cat.fa

echo "Make BLAST db of sym genome seqs" $(date)

makeblastdb -in ptua_sym_genomes_cat.fa -dbtype nucl -out sym_genomes_db

echo "BLAST hifi reads against sym genome seqs" $(date)

blastn \
  -query Ptua_hifi_reads.fasta \
  -db sym_genomes_db \
  -out sym_contaminant_hits_rr.txt \
  -outfmt "6 qseqid sseqid evalue bitscore" \
  -evalue 1e-4

echo "BLAST to sym genome seqs complete" $(date)
