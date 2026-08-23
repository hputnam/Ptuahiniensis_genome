#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 --ntasks-per-node=1
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=100GB
#SBATCH -t 47:00:00
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

echo "Running busco on Ptua assembled and masked genome" $(date)
echo "Creating output directory: Ptua_genome_busco" $(date)
mkdir -p /work/pi_hputnam_uri_edu/Ptua_genome/Ptua_genome_busco/
export PATH="/work/pi_hputnam_uri_edu/conda/envs/env-busco/bin:$PATH"

module load conda/latest 
conda activate /work/pi_hputnam_uri_edu/conda/envs/env-busco
module load uri/main HMMER/3.4-gompi-2023a
python -c "import shutil; print('Resolved hmmsearch path:', shutil.which('hmmsearch'))"

echo "START busco on genome" $(date)

#set query file
query="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/Pocillopora_tuahiniensis_genome_v1.0.fasta"

#configure BUSCO ini file
busco -f -c 15 \
  -i "${query}" \
  -l metazoa_odb10 \
  -o Ptua_genome_busco \
  -m genome \
  --download_path /work/pi_hputnam_uri_edu/lineages

echo "Busco complete" $(date)
