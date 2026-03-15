#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 --ntasks-per-node=1
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=25GB
#SBATCH -t 48:00:00
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

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
target=Ptua_hifiasm_s55.p_ctg.fa \
reads=/work/pi_hputnam_uri_edu/Ptua_genome/Ptua_hifi_filtered_reads.fasta \
out_prefix=ptua_ntlink_s55

echo "Scaffolding of hifiasm primary assembly with ntlinks (rounds = 5) complete!" $(date)
