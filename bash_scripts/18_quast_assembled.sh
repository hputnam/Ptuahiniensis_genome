#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 --ntasks-per-node=1
#SBATCH --partition=uri-cpu
#SBATCH --no-requeue
#SBATCH --mem=25GB
#SBATCH -t 24:00:00
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

module load uri/main
module load QUAST/5.0.2-foss-2021b

echo "Begin quast of assembled and masked genome" $(date)

quast --eukaryote \
/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Ptua_hifiasm_s55.p_ctg.fa.k32.w100.z1000.ntLink.5rounds.fa.masked \
/scratch4/workspace/jillashey_uri_edu-Ptua_genome/Pver_genome_assembly_v1.0.fasta \
/work/pi_hputnam_uri_edu/HI_Genomes/Pmeandrina/Pocillopora_meandrina_HIv1.assembly.fasta \
/work/pi_hputnam_uri_edu/HI_Genomes/PacutaV2/Pocillopora_acuta_HIv2.assembly.fasta \
-o /work/pi_hputnam_uri_edu/Ptua_genome/quast_assembled

echo "Quast complete" $(date)
