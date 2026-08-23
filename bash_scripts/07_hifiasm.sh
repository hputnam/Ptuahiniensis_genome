#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 --ntasks-per-node=8
#SBATCH --partition=uri-cpu
#SBATCH --no-requeue
#SBATCH --mem=100GB
#SBATCH -t 5-00:00:00
#SBATCH -q long
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

module load conda/latest
conda activate /work/pi_hputnam_uri_edu/conda/envs/hifiasm

cd /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Starting assembly with hifiasm" $(date)

hifiasm -o Ptua_hifiasm /work/pi_hputnam_uri_edu/Ptua_genome/Ptua_hifi_reads.fasta --primary -s 0.55 -t 8 2> Ptua_hifiasm_s55_primary.log

echo "Assembly with hifiasm complete!" $(date)

conda deactivate
