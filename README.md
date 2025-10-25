## Sample Info
POC-222
Sample ID 555	Coral tissue and skeleton in DNA/RNA Shield
Sample ID 879	Coral tissue and skeleton in DNA/RNA Shield

## Wetlab Work
DNA extraction and PacBio Amplifi library prep at Genomics and Bioinformatics center /Brigham Young University
FEMTO Pulse Results
Library Prep

## Files from Genohub Project 6470522 - P. tuahiniensis genome
2025-10-23 18:20:50 20377834269 m84100_251021_203206_s3.hifi_reads.bam
2025-10-23 18:20:50  129896502 m84100_251021_203206_s3.hifi_reads.bam.pbi

### Steps

1. Bam2fastq
2. Jellyfish
3. GenomeScope
4. MitoHiFi assembly
4. Blast filtering
5. Hifiasm
6. Quast
7. RepeatModeler
8. RepeatMasker
9. BUSCO
10. funannotate
11. Interproscan
12. EggNOG


## SMRT Link report key info

### HiFi yield (Gb)

	- What to check: Total HiFi bases (and per-barcode if multiplexed).   
	= 1,563,675,269,600 Polymerase Read Bases
	1563675269600

	- Target: Enough to hit your desired coverage (Coverage ≈ (HiFi Gb) ÷ (genome size Gb)).
	- 1563.6752696  ÷ 0.410Gb ~ 3814x 


### Read length distribution (median / N50)

	- 3,957 HiFi reads length (median, bp)
	- 4,864 HiFi Read Length N50 (bp)


### Predicted read accuracy (RQ / Q score)
	- Q48 HiFi Read Quality (median)
	- 97.77% Base Quality ≥Q30 (%)


### Number of HiFi reads & ZMW productivity

### Total HiFi reads and productive ZMWs.
	- 12.3 M HiFi reads
	- 25,165,824 Productive ZMWs


### Passes per read (NP) & CCS settings
	- 27 HiFi Number of Passes (mean)


### Adapter/short-read/low-quality fractions
	- 2.47%Missing adapters (%)

### Contamination red flags

3,076 Number of Control Reads
83,691 Control Read Length Mean
0.91 Control Read Concordance Mean
0.91 Control Read Concordance Mode

### Path to Raw Data
/project/pi_hputnam_uri_edu/raw_sequencing_data/20251023_Ptuahiniensis_PacBio

m84100_251021_203206_s3.hifi_reads.bam	
m84100_251021_203206_s3.hifi_reads.bam.pbi

# Generate checksums
md5sum m84100* > 20251023_URI_checksum.txt

04596b06637ec92de0cb432c835a4fa8  m84100_251021_203206_s3.hifi_reads.bam
2a237da20370845fb87aa711b00cd945  m84100_251021_203206_s3.hifi_reads.bam.pbi

# Start Assembly
/work/pi_hputnam_uri_edu/Ptua_genome

mkdir raw
cp /project/pi_hputnam_uri_edu/raw_sequencing_data/20251023_Ptuahiniensis_PacBio/*.bam* /work/pi_hputnam_uri_edu/Ptua_genome/raw

mkdir scripts

```
nano /work/pi_hputnam_uri_edu/Ptua_genome/scripts/checksums.sh
```

```
#!/bin/bash
#SBATCH --job-name=checksum_raw
#SBATCH --nodes=1 --cpus-per-task=8
#SBATCH --mem=250G  # Requested Memory
#SBATCH -p gpu  # Partition
#SBATCH -G 1  # Number of GPUs
#SBATCH --time=06:00:00  # Job time limit
#SBATCH -o slurm-checksum_raw.out  # %j = job ID
#SBATCH -e slurm-checksum_raw.err  # %j = job ID
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

#load modules if needed

#run checksum on raw data
md5sum /work/pi_hputnam_uri_edu/Ptua_genome/raw/*.bam* > 20251023_URI_working.md5
```


```
sbatch /work/pi_hputnam_uri_edu/Ptua_genome/scripts/checksums.sh
```

```
04596b06637ec92de0cb432c835a4fa8  /work/pi_hputnam_uri_edu/Ptua_genome/raw/m84100_251021_203206_s3.hifi_reads.bam
2a237da20370845fb87aa711b00cd945  /work/pi_hputnam_uri_edu/Ptua_genome/raw/m84100_251021_203206_s3.hifi_reads.bam.pbi
```
#### checksums match download


## Convert BAM to FASTQ and summarize

```
nano /work/pi_hputnam_uri_edu/Ptua_genome/scripts/convert_bam2fastq.sh
```

```
#!/bin/bash
#SBATCH --job-name=convert_bam2fastq
#SBATCH --nodes=1 --cpus-per-task=8
#SBATCH --mem=250G  # Requested Memory
#SBATCH -p gpu  # Partition
#SBATCH -G 1  # Number of GPUs
#SBATCH --time=06:00:00  # Job time limit
#SBATCH -o slurm-convert_bam2fastq.out  # %j = job ID
#SBATCH -e slurm-convert_bam2fastq.err  # %j = job ID
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

#load modules if needed
module load conda/latest 

# Activate conda env
conda create -n pbtk -y -c bioconda -c conda-forge pbtk
conda activate pbtk
conda install -y -c bioconda -c conda-forge seqkit

#convert bam to fastq
bam2fastq -o Ptua_hifi_reads /work/pi_hputnam_uri_edu/Ptua_genome/raw/m84100_251021_203206_s3.hifi_reads.bam | pigz -p 32 -n > Ptua_hifi_reads.fastq.gz

#generate fastq summary metrics
seqkit stats Ptua_hifi_reads.fastq.gz


```


```
sbatch /work/pi_hputnam_uri_edu/Ptua_genome/scripts/convert_bam2fastq.sh
```


|file   | format  | type |  num_seqs   | sum_len  | min_len  | avg_len |  max_len|
|---|---|---|---|---|---|---|---|
`Ptua_hifi_reads.fastq.gz` | FASTQ | DNA | 12,313,988 |54,955,182,557 | 91 | 4,462.8 |   24,697



### sanity check with manual blast of read from fastq file
first read hit to SAR covid, not ideal, but it is a super short region on the ends of a long sequence

second read hit to Pocillopora verrucosa, great news!

third read hit to Pocillopora verrucosa, great news!


## Convert FASTQ to FASTA

```
nano /work/pi_hputnam_uri_edu/Ptua_genome/scripts/convert_fastq_fasta.sh
```

```
#!/bin/bash
#SBATCH --job-name=convert_fastq_fasta
#SBATCH --nodes=1 --cpus-per-task=8
#SBATCH --mem=250G  # Requested Memory
#SBATCH -p gpu  # Partition
#SBATCH -G 1  # Number of GPUs
#SBATCH --time=06:00:00  # Job time limit
#SBATCH -o slurm-convert_fastq_fasta.out  # %j = job ID
#SBATCH -e slurm-convert_fastq_fasta.err  # %j = job ID
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

#load modules if needed
module load conda/latest 
conda activate pbtk
conda install -y -c bioconda -c conda-forge seqtk

echo "Convert PacBio fastq file to fasta file" $(date)

seqtk seq -A Ptua_hifi_reads.fastq.gz > Ptua_hifi_reads.fasta

echo "Fastq to fasta complete! Summarize read lengths" $(date)

awk '/^>/ { if (seq) {print header"\t"length(seq)}; header=substr($0,2); seq="" ; next } 
     {seq=seq$0} 
     END {print header"\t"length(seq)}' Ptua_hifi_reads.fasta > Ptua_rr_read_lengths.txt

echo "Read length summary complete" $(date)

```

```
sbatch /work/pi_hputnam_uri_edu/Ptua_genome/scripts/convert_fastq_fasta.sh
```


## describe kmers and estimate nuclear genome size and heterozygosity
Jellyfish and Genoscope


```
nano /work/pi_hputnam_uri_edu/Ptua_genome/scripts/kmercount_jellyfish.sh
```

```
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

```


```
sbatch /work/pi_hputnam_uri_edu/Ptua_genome/scripts/kmercount_jellyfish.sh
```

scp -r hputnam_uri_edu@unity.rc.umass.edu://work/pi_hputnam_uri_edu/Ptua_genome/Ptua_k31.histo.txt /Users/hputnam/MyProjects/Ptuahiniensis_genome/


### genomescope2
Estimate genome heterozygosity, repeat content, and size from sequencing reads using a kmer-based statistical approach.
http://genomescope.org/genomescope2.0/









Chromosome level assembly for P. verrucosa
https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_036669915.1/

### MitoHiFi assembly to assemble the mitochondrial genome
https://www.sciencedirect.com/science/article/pii/S0378111907003666?via%3Dihub
https://www.ncbi.nlm.nih.gov/nuccore/EF526302.1 

scp -r /Users/hputnam/Downloads/EF526302.1.* hputnam_uri_edu@unity.rc.umass.edu://work/pi_hputnam_uri_edu/Ptua_genome/ 

mkdir /work/pi_hputnam_uri_edu/Ptua_genome/mito

```
nano /work/pi_hputnam_uri_edu/Ptua_genome/scripts/mito_assemble.sh
```

```
#!/bin/bash
#SBATCH --job-name=mito_assemble
#SBATCH --nodes=1 --cpus-per-task=8
#SBATCH --mem=250G  # Requested Memory
#SBATCH -p gpu  # Partition
#SBATCH -G 1  # Number of GPUs
#SBATCH --time=12:00:00  # Job time limit
#SBATCH -o slurm-mito_assemble.out  # %j = job ID
#SBATCH -e slurm-mito_assemble.err  # %j = job ID
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

echo "Starting mito assembly with Pocillopora refs" $(date)

#load modules if needed

cd /work/pi_hputnam_uri_edu/Ptua_genome

singularity exec --bind /work/pi_hputnam_uri_edu/Ptua_genome/ docker://ghcr.io/marcelauliano/mitohifi:master mitohifi.py -r Ptua_hifi_reads.fasta \
 -f EF526302.1.fasta -g EF526302.1.gb \
 -t 8 \
 -o 5 #invert code 

echo "Mito assembly complete!" $(date)
```

```
sbatch /work/pi_hputnam_uri_edu/Ptua_genome/scripts/mito_assemble.sh
```
scp -r hputnam_uri_edu@unity.rc.umass.edu://work/pi_hputnam_uri_edu/Ptua_genome/final_mitogenome.fasta /Users/hputnam/MyProjects/Ptuahiniensis_genome/





4. Blast filtering to remove non-coral reads




5. Hifiasm to assembly
6. ntlinks to further scaffold the assembly
7. Ragout (Reference-Assisted Genome Ordering UTility) is a tool for chromosome-level scaffolding using multiple references. - Consider running this 
6. Quast to report assembly stats
7. BUSCO to report assembly stats
8. RepeatModeler for structural annotation
9. RepeatMasker for structural annotation
10. funannotate for structural annotation and functional annotation
11. Interproscan for functional annotation
12. EggNOG for functional annotation