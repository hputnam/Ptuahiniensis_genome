#!/usr/bin/env bash
#SBATCH --export=ALL
#SBATCH --ntasks=1 --cpus-per-task=24
#SBATCH --partition=uri-cpu,cpu,cpu-preempt
#SBATCH --no-requeue
#SBATCH --mem=100GB
#SBATCH -t 72:00:00
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

module load uri/main
module load conda/latest
conda activate /work/pi_hputnam_uri_edu/conda/envs/ntlink 

echo "Starting scaffolding of hifiasm primary assembly with ntlinks (rounds = 5)" $(date)

cd /scratch4/workspace/jillashey_uri_edu-Ptua_genome

ntLink_rounds run_rounds_gaps \
t=36 \
g=100 \
rounds=5 \
gap_fill \
target=Ptua_primary_clean.fasta \
reads=/work/pi_hputnam_uri_edu/Ptua_genome/Ptua_hifi_reads.fastq.gz \
out_prefix=Ptua_primary_clean_ntlinks

echo "Scaffolding of hifiasm primary assembly with ntlinks (rounds = 5) complete!" $(date)
