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
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

module load conda/latest 
conda activate /work/pi_hputnam_uri_edu/conda/envs/repeatmodeler 

cd /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Building repeatmodeler database" $(date)

BuildDatabase -name ptua_repeat_db Pocillopora_tuahiniensis_genome_v1.0.fasta

echo "Db build complete, run repeatmodeler" $(date)

RepeatModeler -database ptua_repeat_db -engine ncbi -LTRStruct -threads 15

echo "Repeatmodeler complete" $(date)

conda deactivate
