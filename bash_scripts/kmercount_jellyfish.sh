#!/bin/bash
#SBATCH --job-name=kmercount_jellyfish
#SBATCH --nodes=1 --cpus-per-task=8
#SBATCH --mem=250G  # Requested Memory
#SBATCH -p gpu  # Partition
#SBATCH -G 1  # Number of GPUs
#SBATCH --time=12:00:00  # Job time limit
#SBATCH -o slurm-kmercount_jellyfish.out  # %j = job ID
#SBATCH -e slurm-kmercount_jellyfish.err  # %j = job ID
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

#load modules if needed
module load conda/latest 

# Activate conda env
conda activate pbtk   # or your env
conda install -y -c bioconda -c conda-forge jellyfish pigz

#run jellyfish kmer count 
pigz -dc Ptua_hifi_reads.fastq.gz \
  | jellyfish count -m 31 -C -s 1G -t 32 /dev/fd/0 -o Ptua_k31.jf
  
echo "JF counting complete" $(date)

#generate histo for genomescope  
jellyfish histo -t 32 Ptua_k31.jf > Ptua_k31.histo.txt
jellyfish histo -t 32 -l 2 Ptua_k31.jf > Ptua_k31.L2.histo.txt   # filters singletons (optional)

echo "JF histo complete" $(date)
