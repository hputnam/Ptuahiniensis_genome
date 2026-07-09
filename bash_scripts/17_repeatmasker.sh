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
conda activate /work/pi_hputnam_uri_edu/conda/envs/repeatmodeler 

cd /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Run repeatmasker using the output from repeatmodeler" $(date)

RepeatMasker \
	-lib ptua_repeat_db-families.fa \
	-engine ncbi \
	-parallel 20 \
	-gff -xsmall -s \
	-poly \
	-dir ptua_softmasked \
	-a \
	Ptua_hifiasm_s55.p_ctg.fa.k32.w100.z1000.ntLink.5rounds.fa

echo "Repeatmasker complete" $(date)
