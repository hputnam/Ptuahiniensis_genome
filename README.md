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

### Main Steps

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

### Resources 
[Chromosome level assembly for P. verrucosa](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_036669915.1/)




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
GenomeScope version 2.0
input file = user_uploads/XRcuKFUQFpK0dZp0UUke = Ptua_k31.histo.txt
output directory = user_data/XRcuKFUQFpK0dZp0UUke
p = 2
k = 31
initial kmercov estimate = 73
max_kmercov = 600

[Results](http://genomescope.org/genomescope2.0/analysis.php?code=XRcuKFUQFpK0dZp0UUke) 
GenomeScope2 (k = 31, diploid) indicates a ~290 Mb haploid genome with ~85 % unique content, ~1.4 % heterozygosity, < 0.5 % sequencing error, and minimal duplication



## MitoHiFi assembly to assemble the mitochondrial genome

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


#### Check the Mito Assembly
The mitochondrial genome was successfully assembled using MitoHifi.

MitoFinder found a single mitochondrial contig. Evidences of circularization could not be found, but everyother step was successful

The assembled P. tuahiniensis mitogenome is 16884 bp in length with 16 protein-coding genes and contains 2 transfer RNA (tRNA) coding genes.




## Blast filtering to remove non-coral reads

BLAST Ptua hifi raw reads against the following for contaminant removal: 

- Euk contam seqs 
- Viral representative genomes (`/datasets/bio/ncbi-db/2025-11-16`)
- Prok representative genomes (`/datasets/bio/ncbi-db/2025-11-16`)
- Sym genomes 
- Mito -- do the above filtering steps first, rerun mito hifi and then filter mito reads out

`nano blastn_contam_euk.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 --ntasks-per-node=2
#SBATCH --partition=uri-cpu
#SBATCH --no-requeue
#SBATCH --mem=100GB
#SBATCH -t 24:00:00
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

cd /work/pi_hputnam_uri_edu/Ptua_genome

module load uri/main
module load BLAST+/2.15.0-gompi-2023a 

#wget contam_screen/ftp.ncbi.nlm.nih.gov/pub/kitts/contam_in_euks.fa.gz
#gunzip contam_screen/contam_in_euks.fa.gz

echo "Make BLAST db of euk contam seqs" $(date)

makeblastdb -in contam_screen/contam_in_euks.fa -dbtype nucl -out contam_screen/contam_euk_db

echo "BLAST hifi reads against euk contam seqs" $(date)

blastn \
  -query Ptua_hifi_reads.fasta \
  -db contam_screen/contam_euk_db \
  -out euk_contaminant_hits_rr.txt \
  -outfmt "6 qseqid sseqid evalue bitscore" \
  -evalue 1e-4
  
echo "BLAST to euk contam seqs complete" $(date)
```

Submitted batch job 49030581

Unity has the viral and prok dbs downloaded here: `/datasets/bio/ncbi-db`. They are updated every two weeks. 

`nano blastn_contam_viral.sh`

```
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

## No need to build blast db, viral db already created 

echo "BLAST hifi reads against viral genome seqs" $(date)

blastn \
  -query Ptua_hifi_reads.fasta \
  -db /datasets/bio/ncbi-db/2025-11-16/ref_viruses_rep_genomes \
  -out viral_contaminant_hits_rr.txt \
  -outfmt "6 qseqid sseqid evalue bitscore" \
  -evalue 1e-4
  
echo "BLAST to viral genome seqs complete" $(date)
```

Submitted batch job 49030637

`nano blastn_contam_prok.sh`

```
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

## No need to build blast db, prok db already created 

echo "BLAST hifi reads against prok genome seqs" $(date)

blastn \
  -query Ptua_hifi_reads.fasta \
  -db /datasets/bio/ncbi-db/2025-11-16/ref_prok_rep_genomes \
  -out prok_contaminant_hits_rr.txt \
  -outfmt "6 qseqid sseqid evalue bitscore" \
  -evalue 1e-4
  
echo "BLAST to prok genome seqs complete" $(date)
```

Submitted batch job 49030912

Symbiont genomes are here: `/work/pi_hputnam_uri_edu/Symbiont_Genomes`. `nano blastn_contam_sym.sh`

```
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
```

Submitted batch job 49031277. 

Filter so that hits with bit score <1000 are removed and remove the larger blast file.

```
awk '$NF > 1000' viral_contaminant_hits_rr.txt > viral_contaminant_hits_rr_bit1000.txt
wc -l viral_contaminant_hits_rr_bit1000.txt
38 viral_contaminant_hits_rr_bit1000.txt
rm viral_contaminant_hits_rr.txt

awk '$NF > 1000' euk_contaminant_hits_rr.txt > euk_contaminant_hits_rr_bit1000.txt
wc -l euk_contaminant_hits_rr_bit1000.txt
416 euk_contaminant_hits_rr_bit1000.txt
rm euk_contaminant_hits_rr.txt

awk '$NF > 1000' prok_contaminant_hits_rr.txt > prok_contaminant_hits_rr_bit1000.txt
wc -l prok_contaminant_hits_rr_bit1000.txt
767239 prok_contaminant_hits_rr_bit1000.txt
rm prok_contaminant_hits_rr.txt

awk '$NF > 1000' sym_contaminant_hits_rr.txt > sym_contaminant_hits_rr_bit1000.txt
wc -l sym_contaminant_hits_rr_bit1000.txt
9573384 sym_contaminant_hits_rr_bit1000.txt
rm sym_contaminant_hits_rr.txt
```

Cat contamination files together and make list of unique reads to remove from the fasta file. 

```
cat viral_contaminant_hits_rr_bit1000.txt euk_contaminant_hits_rr_bit1000.txt prok_contaminant_hits_rr_bit1000.txt sym_contaminant_hits_rr_bit1000.txt > contamaminant_hits_rr_bit1000.txt

awk '{print $1}' contamaminant_hits_rr_bit1000.txt | sort -u > reads_to_remove.txt
wc -l reads_to_remove.txt 
445169 reads_to_remove.txt
```

Remove contaminant reads from raw reads. `nano filter_contaminants.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 --ntasks-per-node=2
#SBATCH --partition=uri-cpu
#SBATCH --no-requeue
#SBATCH --mem=100GB
#SBATCH -t 100:00:00
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

module load uri/main
module load seqtk/1.4-GCC-12.3.0

echo "Make list of all reads and remove contam reads" $(date)
grep "^>" Ptua_hifi_reads.fasta | sed 's/^>//' > Ptua_fasta_reads.txt
grep -v -F -f reads_to_remove.txt Ptua_fasta_reads.txt > filtered_reads.txt

echo "Filtering hifi reads that passed contamination filtering" $(date)

cd /work/pi_hputnam_uri_edu/Ptua_genome

seqtk subseq Ptua_hifi_reads.fasta filtered_reads.txt > Ptua_hifi_filtered_reads.fasta

grep -c ">" Ptua_hifi_reads.fasta
grep -c ">" Ptua_hiti_filtered_reads.fasta

echo "Filtering complete!" $(date)
```

Submitted batch job 49203578

Rerun the mito hifi script (`mito_assemble.sh`) with filtered reads (`Ptua_hiti_filtered_reads.fasta`) as input. Submitted batch job 49388384. 

Mitochondrial genome was successfully assembled, and two mito contigs were found (`ptg000010l` and `ptg000015l`). Evidence of circularization was not found in either contig but all other steps were successful. `ptg000015l` was selected by the software as the most representative contig. The final mitogeneome (`ptg000015l`) is 15614 bp in length with GC content of 31.02%. The mitogenome contains 12 protein coding genes, 3 tRNA coding genes, and two rRNA coding genes. 

Blast mitogenome against raw reads for removal. `nano blastn_contam_mito.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 --ntasks-per-node=2
#SBATCH --partition=uri-cpu
#SBATCH --no-requeue
#SBATCH --mem=100GB
#SBATCH -t 24:00:00
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

cd /work/pi_hputnam_uri_edu/Ptua_genome

module load uri/main
module load BLAST+/2.15.0-gompi-2023a 

echo "Make BLAST db of mitogenome seqs" $(date)

makeblastdb -in final_mitogenome.fasta -dbtype nucl -out contam_screen/mito_db

echo "BLAST hifi reads against euk contam seqs" $(date)

blastn \
  -query Ptua_hifi_reads.fasta \
  -db contam_screen/mito_db \
  -out mito_contaminant_hits_rr.txt \
  -outfmt "6 qseqid sseqid evalue bitscore" \
  -evalue 1e-4
  
echo "BLAST to euk mitogenome seqs complete" $(date)
```

Submitted batch job 49391771. Filter so that hits with bit score <1000 are removed and remove the larger blast file.

```
awk '$NF > 1000' mito_contaminant_hits_rr.txt > mito_contaminant_hits_rr_bit1000.txt
wc -l mito_contaminant_hits_rr_bit1000.txt
55972 mito_contaminant_hits_rr_bit1000.txt
rm mito_contaminant_hits_rr.txt
```

Cat contamination files together and make list of unique reads to remove from the fasta file. 

```
cat viral_contaminant_hits_rr_bit1000.txt euk_contaminant_hits_rr_bit1000.txt prok_contaminant_hits_rr_bit1000.txt sym_contaminant_hits_rr_bit1000.txt mito_contaminant_hits_rr_bit1000.txt > contamaminant_hits_rr_bit1000.txt

awk '{print $1}' contamaminant_hits_rr_bit1000.txt | sort -u > reads_to_remove.txt
wc -l reads_to_remove.txt 
479623 reads_to_remove.txt
```

Rerun `filter_contaminants.sh` with all contaminants identified (eukaryote, prokaryote, viral, symbiont, mitochondrial). Submitted batch job 49402682. The raw read fasta file (`Ptua_hifi_reads.fasta`) has 12313988 reads, while the cleaned and filtered fasta file (`Ptua_hiti_filtered_reads.fasta`) has 11834365 reads. 

## Hifiasm to assembly

Install [Hifiasm](https://github.com/chhylp123/hifiasm) on Unity.

```
cd /work/pi_hputnam_uri_edu/conda/envs
module load conda/latest # need to load before making any conda envs
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict
conda create --prefix /work/pi_hputnam_uri_edu/conda/envs/hifiasm hifiasm
conda activate /work/pi_hputnam_uri_edu/conda/envs/hifiasm 
```

Run hifiasm on cleaned and filtered reads. `nano hifiasm.sh`

```
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

cd /work/pi_hputnam_uri_edu/Ptua_genome

echo "Starting assembly with hifiasm" $(date)

hifiasm -o Ptua_hifiasm Ptua_hifi_filtered_reads.fasta --primary -s 0.55 -t 8 2> Ptua_hifiasm_s55_primary.log

echo "Assembly with hifiasm complete!" $(date)

conda deactivate
```

Submitted batch job 49403559. This will take a few days to run. 

## ntlink to further scaffold the assembly

Install [ntlink](https://github.com/bcgsc/ntLink) on Unity.

```
cd /work/pi_hputnam_uri_edu/conda/envs
module load conda/latest # need to load before making any conda envs
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict
conda create --prefix /work/pi_hputnam_uri_edu/conda/envs/ntlink ntlink
conda activate /work/pi_hputnam_uri_edu/conda/envs/ntlink 
```


7. Ragout (Reference-Assisted Genome Ordering UTility) is a tool for chromosome-level scaffolding using multiple references. - Consider running this 
6. Quast to report assembly stats
7. BUSCO to report assembly stats
8. RepeatModeler for structural annotation
9. RepeatMasker for structural annotation
10. funannotate for structural annotation and functional annotation
11. Interproscan for functional annotation
12. EggNOG for functional annotation