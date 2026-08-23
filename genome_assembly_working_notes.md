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

## Generate checksums
md5sum m84100* > 20251023_URI_checksum.txt

04596b06637ec92de0cb432c835a4fa8  m84100_251021_203206_s3.hifi_reads.bam
2a237da20370845fb87aa711b00cd945  m84100_251021_203206_s3.hifi_reads.bam.pbi

## Start Assembly
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

Submitted batch job 49403559. Assembly took ~24 hours to run. The primary assembly is `Ptua_hifiasm.p_ctg.gfa` and the alternate assembly is `Ptua_hifiasm.a_ctg.gfa`. See hifiasm support [documents](https://gensoft.pasteur.fr/docs/hifiasm/0.16.1/interpreting-output.html) for information about the output files. Convert output files from gfa to fa. 

```
awk '/^S/{print ">"$2"\n"$3}' Ptua_hifiasm.p_ctg.gfa | fold > Ptua_hifiasm.p_ctg.fa
grep -c ">" Ptua_hifiasm.p_ctg.fa
2117

awk '/^S/{print ">"$2"\n"$3}' Ptua_hifiasm.a_ctg.gfa | fold > Ptua_hifiasm.a_ctg.fa
grep -c ">" Ptua_hifiasm.a_ctg.fa
6959
```

The primary assembly is quite large. Might be worth it to rerun hifiasm with the -s flag set to 0.3 and the `–hom-cov` to 150 based on the log file. Usually, hifiasm infers automatically by default but it would be good to put these in. 

Run Quast and Busco on initial assembly. 

`nano quast_hifiasm.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 --ntasks-per-node=1
#SBATCH --partition=cpu,uri-cpu
#SBATCH --no-requeue
#SBATCH --mem=25GB
#SBATCH -t 24:00:00
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

module load uri/main
module load QUAST/5.0.2-foss-2021b

echo "Begin quast of primary and alternate assemblies (-s 0.55)" $(date)

cd /work/pi_hputnam_uri_edu/Ptua_genome

quast --eukaryote \
Ptua_hifiasm.p_ctg.fa \
Ptua_hifiasm.a_ctg.fa \
/work/pi_hputnam_uri_edu/HI_Genomes/Pmeandrina/Pocillopora_meandrina_HIv1.assembly.fasta \
/work/pi_hputnam_uri_edu/HI_Genomes/PacutaV2/Pocillopora_acuta_HIv2.assembly.fasta \
-o /work/pi_hputnam_uri_edu/Ptua_genome/quast

echo "Quast complete" $(date)
```

Submitted batch job 49468427. The assembly doesn't look great. The N50 is low (379661 bp) and the largest contig is only 2017673 bp. In comparison, the Pmea genome has an N50 of 10024633 bp and the largest contig is 21651136. 

`nano busco_hifiasm.sh`

```
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

module load conda/latest 

conda activate /work/pi_hputnam_uri_edu/conda/envs/env-busco/

cd /work/pi_hputnam_uri_edu/Ptua_genome

echo "Begin busco of primary assembly (-s 0.55)" $(date)

busco -i Ptua_hifiasm.p_ctg.fa -l /work/pi_hputnam_uri_edu/lineages/metazoa_odb12 -o /work/pi_hputnam_uri_edu/Ptua_genome/busco -m genome

echo "Busco complete" $(date)
```

Submitted batch job 49471519. Busco failed, need to rerun. 

Run iterations of hifiasm with `-s` set to 0.35, 0.45, 0.55, and 0.65 and `–-hom-cov 150`. Submitted batch jobs 49488122, 49488399, 49488404, and 49488406, respectively. 

Convert output files from gfa to fa. 

```
# s -0.35
awk '/^S/{print ">"$2"\n"$3}' Ptua_hifiasm_s35.p_ctg.gfa | fold > Ptua_hifiasm_s35.p_ctg.fa
awk '/^S/{print ">"$2"\n"$3}' Ptua_hifiasm_s35.a_ctg.gfa | fold > Ptua_hifiasm_s35.a_ctg.fa

# s -0.45
awk '/^S/{print ">"$2"\n"$3}' Ptua_hifiasm_s45.p_ctg.gfa | fold > Ptua_hifiasm_s45.p_ctg.fa
awk '/^S/{print ">"$2"\n"$3}' Ptua_hifiasm_s45.a_ctg.gfa | fold > Ptua_hifiasm_s45.a_ctg.fa

# s -0.55
awk '/^S/{print ">"$2"\n"$3}' Ptua_hifiasm_s55.p_ctg.gfa | fold > Ptua_hifiasm_s55.p_ctg.fa
awk '/^S/{print ">"$2"\n"$3}' Ptua_hifiasm_s55.a_ctg.gfa | fold > Ptua_hifiasm_s55.a_ctg.fa

# s -0.65
awk '/^S/{print ">"$2"\n"$3}' Ptua_hifiasm_s65.p_ctg.gfa | fold > Ptua_hifiasm_s65.p_ctg.fa
awk '/^S/{print ">"$2"\n"$3}' Ptua_hifiasm_s65.a_ctg.gfa | fold > Ptua_hifiasm_s65.a_ctg.fa
```

Run busco and quast on these assemblies. 

`nano quast_hifiasm.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 --ntasks-per-node=1
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=25GB
#SBATCH -t 24:00:00
#SBATCH --mail-type=BEGIN,END,FAIL #email you when job starts, stops and/or fails
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /work/pi_hputnam_uri_edu/Ptua_genome

module load uri/main
module load QUAST/5.0.2-foss-2021b

echo "Begin quast of primary and alternate assembly iterations" $(date)

cd /work/pi_hputnam_uri_edu/Ptua_genome

quast --eukaryote \
Ptua_hifiasm_s35.p_ctg.fa \
Ptua_hifiasm_s45.p_ctg.fa \
Ptua_hifiasm_s55.p_ctg.fa \
Ptua_hifiasm_s65.p_ctg.fa \
/work/pi_hputnam_uri_edu/HI_Genomes/Pmeandrina/Pocillopora_meandrina_HIv1.assembly.fasta \
/work/pi_hputnam_uri_edu/HI_Genomes/PacutaV2/Pocillopora_acuta_HIv2.assembly.fasta \
-o /work/pi_hputnam_uri_edu/Ptua_genome/quast

echo "Quast complete" $(date)
```

Submitted batch job 49526093

Outline of busco script for all assembly iterations: `nano busco_hifiasm_s35.sh`

```
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

echo "Running busco on Ptua assembly with -s 0.35" $(date)
echo "Creating output directory: Ptua_hifiasm_s35_busco" $(date)
mkdir -p /work/pi_hputnam_uri_edu/Ptua_genome/Ptua_hifiasm_s35_busco/
export PATH="/work/pi_hputnam_uri_edu/conda/envs/env-busco/bin:$PATH"

module load conda/latest 
conda activate /work/pi_hputnam_uri_edu/conda/envs/env-busco
module load uri/main HMMER/3.4-gompi-2023a
python -c "import shutil; print('Resolved hmmsearch path:', shutil.which('hmmsearch'))"

echo "START Ptua_hifiasm_s35" $(date)

#set query file
query="/work/pi_hputnam_uri_edu/Ptua_genome/Ptua_hifiasm_s35.p_ctg.fa"

#configure BUSCO ini file
busco --config /work/pi_hputnam_uri_edu/conda/envs/env-busco/myconfig.ini \
  -f -c 15 \
  -i "${query}" \
  -l metazoa_odb10 \
  -o Ptua_hifiasm_s35_busco_output \
  -m genome \
  --download_path /work/pi_hputnam_uri_edu/lineages

echo "STOP Ptua_hifiasm_s35" $(date)
```

Submitted batch job 49525836. 

Here are the busco results for `Ptua_hifiasm_s35`: 

```
C:96.5%[S:92.0%,D:4.5%],F:0.9%,M:2.5%,n:954,E:4.0%
	921	Complete BUSCOs (C)	(of which 37 contain internal stop codons)
	878	Complete and single-copy BUSCOs (S)
	43	Complete and duplicated BUSCOs (D)
	9	Fragmented BUSCOs (F)			   
	24	Missing BUSCOs (M)			   
	954	Total BUSCO groups searched
Assembly Statistics:
	1881	Number of scaffolds
	1881	Number of contigs
	346892374	Total length
	0.000%	Percent gaps
	411 KB	Scaffold N50
	411 KB	Contigs N50
```

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

Move forward with the s55 assembly(`Ptua_hifiasm_s55.p_ctg.fa`). Working in scratch directory now. 

Run ntlinks to further scaffold assembly. `nano ntlinks.sh`

```
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
```

Submitted batch job 53659282

## RepeatModeler 

Install [RepeatModeler](https://github.com/Dfam-consortium/RepeatModeler) on Unity.

```
cd /work/pi_hputnam_uri_edu/conda/envs
module load conda/latest # need to load before making any conda envs
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict
conda create --prefix /work/pi_hputnam_uri_edu/conda/envs/repeatmodeler repeatmodeler
conda activate /work/pi_hputnam_uri_edu/conda/envs/repeatmodeler 
```

Run repeatmodeler to identify genomic repeats. `nano repeatmodeler.sh`

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
conda activate /work/pi_hputnam_uri_edu/conda/envs/repeatmodeler 

cd /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Building repeatmodeler database" $(date)

BuildDatabase -engine ncbi -name ptua_repeat_db Ptua_hifiasm_s55.p_ctg.fa.k32.w100.z1000.ntLink.5rounds.fa

echo "Db build complete, run repeatmodeler" $(date)

RepeatModeler -database ptua_repeat_db -engine ncbi -LTRStruct -threads 15

echo "Repeatmodeler complete" $(date)

conda deactivate
```

Submitted batch job 53679982. 

Count number of families 

```
grep -c ">" ptua_repeat_db-families.fa
2235
```

Count how many classifications each family has 

```
grep ">" ptua_repeat_db-families.fa | cut -
d'#' -f2 | cut -d' ' -f1 | sort | uniq -c | sort -nr
   1631 Unknown
     74 LTR/Gypsy
     71 LINE/L2
     60 LINE/Penelope
     57 LTR/Unknown
     39 LTR/Pao
     35 DNA/Sola-3
     28 RC/Helitron
     18 DNA/Crypton-A
     17 LINE/Rex-Babar
     16 LINE/CR1
     16 DNA/PIF-Harbinger
     15 LTR/DIRS
     15 LINE/RTE-BovB
     14 tRNA
     14 DNA/TcMar-Tc2
     11 DNA/Maverick
     10 LINE/L1-Tx1
      9 DNA/PIF-ISL2EU
      6 LTR/Copia
      5 SINE/MIR
      5 DNA
      4 snRNA
      4 LTR/Ngaro
      4 LINE/CRE
      4 DNA/CMC-Chapaev
      3 LINE
      3 DNA/MULE-NOF
      3 DNA/Merlin
      3 DNA/Kolobok-T2
      3 DNA/Kolobok-Hydra
      3 DNA/IS3EU
      3 DNA/hAT-Tip100
      3 DNA/hAT-Ac
      3 DNA/CMC-EnSpm
      2 SINE/tRNA-V
      2 rRNA
      2 LINE/L1
      2 DNA/TcMar-Tc1
      2 DNA/TcMar-ISRm11
      2 DNA/PiggyBac
      2 DNA/MULE-MuDR
      1 SINE/5S-Deu-L2
      1 LTR
      1 LINE/CR1-Zenon
      1 DNA/TcMar-Tigger
      1 DNA/MULE-F
      1 DNA/hAT-hAT5
      1 DNA/hAT-hAT1
      1 DNA/Dada
      1 DNA/Crypton-V
      1 DNA/Academ-H
      1 DNA/Academ-2
      1 DNA/Academ-1
```

## RepeatMasker 

Install [RepeatModeler](https://www.repeatmasker.org/) on Unity.

```
cd /work/pi_hputnam_uri_edu/conda/envs
module load conda/latest # need to load before making any conda envs
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict
conda create --prefix /work/pi_hputnam_uri_edu/conda/envs/repeatmasker repeatmasker
conda activate /work/pi_hputnam_uri_edu/conda/envs/repeatmasker 
```

Run repeatmodeler to identify genomic repeats. `nano repeatmasker.sh`

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
```

Submitted batch job 53707479


this will be important for functional annotation: https://unityhpc.org/documentation/datasets/ 

examples of recent coral genome preprint releases: https://www.biorxiv.org/content/10.64898/2026.02.26.708201v1.full.pdf (https://github.com/SequAna-Ukon/Porites_harrisoni_genome/blob/main/07.functional_annotation.sh; https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_040938025.2/)

## Quast on assembled and masked genome 

Run Quast on the assembled and masked genome, as well as other published Pocillopora genomes. `nano quast_assembled.sh`

```
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
```

Submitted batch job 53726073

## Busco on assembled and masked genome 

Run busco on assembled and masked genome. `nano busco_assembled.sh`

```
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
query="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Ptua_hifiasm_s55.p_ctg.fa.k32.w100.z1000.ntLink.5rounds.fa.masked"

busco -f -c 15 \
  -i "${query}" \
  -l metazoa_odb10 \
  -o Ptua_genome_busco \
  -m genome \
  --download_path /work/pi_hputnam_uri_edu/lineages

echo "Busco complete" $(date)
```

Submitted batch job 53752937

Busco results: 

```
    -------------------------------------------------------------------------------------------
    |Results from dataset metazoa_odb10                                                        |
    -------------------------------------------------------------------------------------------
    |C:96.8%[S:91.5%,D:5.2%],F:0.8%,M:2.4%,n:954,E:4.6%                                        |
    |923    Complete BUSCOs (C)    (of which 42 contain internal stop codons)                  |
    |873    Complete and single-copy BUSCOs (S)                                                |
    |50    Complete and duplicated BUSCOs (D)                                                  |
    |8    Fragmented BUSCOs (F)                                                                |
    |23    Missing BUSCOs (M)                                                                  |
    |954    Total BUSCO groups searched                                                        |
    -------------------------------------------------------------------------------------------
```

## Braker3 for structural assembly 

[Braker](https://github.com/Gaius-Augustus/BRAKER) uses genomic and RNAseq data to generate gene structure annotations in novel genomes. 
- Citation: Gabriel, L., Bruna, T., Hoff, K. J., Ebel, M., Lomsadze, A., Borodovsky, M., Stanke, M. (2024). BRAKER3: Fully Automated Genome Annotation Using RNA-Seq and Protein Evidence with GeneMark-ETP, AUGUSTUS and TSEBRA. Genome Research, doi:10.1101/gr.278090.123

Install as a job. I had to specify the cache dir for braker3 to install or else I was having permission issues. `nano pull_braker.sh`

```
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

echo "Installing braker3 and dependencies" $(date)

module load apptainer/latest

# Set your custom cache/tmp dirs to avoid permission errors
export APPTAINER_CACHEDIR=/scratch4/workspace/jillashey_uri_edu-Ptua_genome/.apptainer_cache
export APPTAINER_TMPDIR=/scratch4/workspace/jillashey_uri_edu-Ptua_genome/.apptainer_cache

# Create the directory if it doesn't exist
mkdir -p $APPTAINER_CACHEDIR

# Pull the image
apptainer pull /scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3.sif docker://teambraker/braker3:latest
```

Submitted batch job 57466957

Before running braker, I need to do a bunch of stuff boo. So I think I'm going to run it with the RNAseq and protein option. This is the 'native' OG mode for running braker and its good to give it as much information as possible. For the RNAseq data, we have the aligned bam files on [Gannett](https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/), so I need to download all that data. I also need a bunch of protein datasets. Specifically, I'm going to use: 

- The Ptua PASA protein output on [Gannett](https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/00.30-F-Ptua-transcriptome-assembly-Trinity/PASA/__all_transcripts.fasta.transdecoder_dir/longest_orfs.pep) -- this was generated by Sam White from the transcriptome assembly. 
- Metazoan protein seqs from [OrthoDB](https://bioinf.uni-greifswald.de/bioinf/partitioned_odb12/) -- it is helpful if braker has protein seqs from distantly related species too. 
	- To cite: Fredrik Tegenfeldt, Dmitry Kuznetsov, Mosè Manni, Matthew Berkeley, Evgeny M Zdobnov, Evgenia V Kriventseva, OrthoDB and BUSCO update: annotation of orthologs with wider sampling of genomes, Nucleic Acids Research, 2024; gkae987, https://doi.org/10.1093/nar/gkae987.
- Proteins from closely related species
	- Pdam proteins from [reefgenomics](http://pdam.reefgenomics.org/download/) -- Cunning et al. 2018
	- Pverr proteins from [reefgenomics](http://pver.reefgenomics.org/download/) -- Buitrago-Lopez et al. 2020
	- Pmea proteins from [cyanophora](http://cyanophora.rutgers.edu/Pocillopora_meandrina/) -- v1, Stephens et al. 2022 
	- Pact proteins from [cyanophora](http://cyanophora.rutgers.edu/Pocillopora_acuta/) -- v2, Stephens et al. 2022

Lets get the proteins first since that is easier. All downlaoded on 7/7/26. 

```
cd 
wget http://pdam.reefgenomics.org/download/pdam_proteins.fasta.gz
wget http://pver.reefgenomics.org/download/Pver_proteins_names_v1.0.faa.gz
wget http://cyanophora.rutgers.edu/Pocillopora_acuta/Pocillopora_acuta_HIv2.genes.pep.faa.gz
wget http://cyanophora.rutgers.edu/Pocillopora_meandrina/Pocillopora_meandrina_HIv1.genes.pep.faa.gz
wget https://bioinf.uni-greifswald.de/bioinf/partitioned_odb12/Metazoa.fa.gz
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/00.30-F-Ptua-transcriptome-assembly-Trinity/PASA/__all_transcripts.fasta.transdecoder_dir/longest_orfs.pep
```

Submit the gunzip as a job since the files are huge. `nano unzip_proteins.sh`

```
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

cd /scratch4/workspace/jillashey_uri_edu-Ptua_genome/protein_seqs

echo "unzipping and catting protein files for braker" $(date)

gunzip * 

# Cat together 
cat pdam_proteins.fasta Pver_proteins_names_v1.0.faa Pocillopora_acuta_HIv2.genes.pep.faa Pocillopora_meandrina_HIv1.genes.pep.faa Metazoa.fa longest_orfs.pep > raw_proteins_for_braker.fa

# Strip out trailing stop codons (*)
sed 's/\*$//g' raw_proteins_for_braker.fa > final_proteins_for_braker.fa

echo "Complete" $(date)
```

Submitted batch job 61591524


Download the aligned bam files for the POC data only form e5 project. 

```
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-40-TP1/POC-40-TP1.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-40-TP2/POC-40-TP2.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-40-TP3/POC-40-TP3.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-40-TP4/POC-40-TP4.sorted.bam

wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-42-TP1/POC-42-TP1.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-42-TP2/POC-42-TP2.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-42-TP3/POC-42-TP3.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-42-TP4/POC-42-TP4.sorted.bam

wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-52-TP1/POC-52-TP1.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-52-TP2/POC-52-TP2.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-52-TP3/POC-52-TP3.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-52-TP4/POC-52-TP4.sorted.bam

wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-53-TP1/POC-53-TP1.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-53-TP2/POC-53-TP2.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-53-TP3/POC-53-TP3.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-53-TP4/POC-53-TP4.sorted.bam

wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-57-TP1/POC-57-TP1.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-57-TP2/POC-57-TP2.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-57-TP3/POC-57-TP3.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-57-TP4/POC-57-TP4.sorted.bam

wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-201-TP1/POC-201-TP1.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-201-TP2/POC-201-TP2.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-201-TP3/POC-201-TP3.sorted.bam
# no TP4 for POC-201

wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-219-TP1/POC-219-TP1.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-219-TP2/POC-219-TP2.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-219-TP3/POC-219-TP3.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-219-TP4/POC-219-TP4.sorted.bam

wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-222-TP1/POC-222-TP1.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-222-TP2/POC-222-TP2.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-222-TP3/POC-222-TP3.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-222-TP4/POC-222-TP4.sorted.bam

wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-255-TP1/POC-255-TP1.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-255-TP2/POC-255-TP2.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-255-TP3/POC-255-TP3.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-255-TP4/POC-255-TP4.sorted.bam

wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-259-TP1/POC-259-TP1.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-259-TP2/POC-259-TP2.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-259-TP3/POC-259-TP3.sorted.bam
wget https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/02.20-F-Ptua-RNAseq-alignment-HiSat2/POC-259-TP4/POC-259-TP4.sorted.bam
```

Do everything in scratch just to be safe. `nano braker.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         # Maximizing threads for faster DIAMOND/Augustus runtimes
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=150GB                # Bumped up to handle 39 BAM files + large protein database safely
#SBATCH -t 72:00:00                # Standard 2-day walltime max
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Starting BRAKER3 Annotation Pipeline at:" $(date)

# Load Apptainer module
module load apptainer/latest

# ----------------------------------------------------
# Define Input and Output Paths
# ----------------------------------------------------
GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Ptua_hifiasm_s55.p_ctg.fa.k32.w100.z1000.ntLink.5rounds.fa.masked"
PROTEINS="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/protein_seqs/final_proteins_for_braker.fa"
OUT_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output"

# Comma-separated list of all 39 sorted BAM files
BAM_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/rna_bams"
BAM_FILES="${BAM_DIR}/POC-201-TP1.sorted.bam,${BAM_DIR}/POC-201-TP2.sorted.bam,${BAM_DIR}/POC-201-TP3.sorted.bam,${BAM_DIR}/POC-219-TP1.sorted.bam,${BAM_DIR}/POC-219-TP2.sorted.bam,${BAM_DIR}/POC-219-TP3.sorted.bam,${BAM_DIR}/POC-219-TP4.sorted.bam,${BAM_DIR}/POC-222-TP1.sorted.bam,${BAM_DIR}/POC-222-TP2.sorted.bam,${BAM_DIR}/POC-222-TP3.sorted.bam,${BAM_DIR}/POC-222-TP4.sorted.bam,${BAM_DIR}/POC-255-TP1.sorted.bam,${BAM_DIR}/POC-255-TP2.sorted.bam,${BAM_DIR}/POC-255-TP3.sorted.bam,${BAM_DIR}/POC-255-TP4.sorted.bam,${BAM_DIR}/POC-259-TP1.sorted.bam,${BAM_DIR}/POC-259-TP2.sorted.bam,${BAM_DIR}/POC-259-TP3.sorted.bam,${BAM_DIR}/POC-259-TP4.sorted.bam,${BAM_DIR}/POC-40-TP1.sorted.bam,${BAM_DIR}/POC-40-TP2.sorted.bam,${BAM_DIR}/POC-40-TP3.sorted.bam,${BAM_DIR}/POC-40-TP4.sorted.bam,${BAM_DIR}/POC-42-TP1.sorted.bam,${BAM_DIR}/POC-42-TP2.sorted.bam,${BAM_DIR}/POC-42-TP3.sorted.bam,${BAM_DIR}/POC-42-TP4.sorted.bam,${BAM_DIR}/POC-52-TP1.sorted.bam,${BAM_DIR}/POC-52-TP2.sorted.bam,${BAM_DIR}/POC-52-TP3.sorted.bam,${BAM_DIR}/POC-52-TP4.sorted.bam,${BAM_DIR}/POC-53-TP1.sorted.bam,${BAM_DIR}/POC-53-TP2.sorted.bam,${BAM_DIR}/POC-53-TP3.sorted.bam,${BAM_DIR}/POC-53-TP4.sorted.bam,${BAM_DIR}/POC-57-TP1.sorted.bam,${BAM_DIR}/POC-57-TP2.sorted.bam,${BAM_DIR}/POC-57-TP3.sorted.bam,${BAM_DIR}/POC-57-TP4.sorted.bam"

# ----------------------------------------------------
# Set Sandbox/Cache Directories to prevent permission locks
# ----------------------------------------------------
export APPTAINER_CACHEDIR=/scratch4/workspace/jillashey_uri_edu-Ptua_genome/.apptainer_cache
export APPTAINER_TMPDIR=/scratch4/workspace/jillashey_uri_edu-Ptua_genome/.apptainer_cache
mkdir -p $APPTAINER_CACHEDIR

# ----------------------------------------------------
# Run BRAKER3 via Apptainer Container
# ----------------------------------------------------
# -B binds both /work and /scratch4 file systems so they are visible inside the container
apptainer exec -B /scratch4 /scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3.sif \
    braker.pl \
    --genome=${GENOME} \
    --bam=${BAM_FILES} \
    --prot_seq=${PROTEINS} \
    --workingdir=${OUT_DIR} \
    --threads=${SLURM_CPUS_PER_TASK} \
    --gff3

echo "BRAKER3 pipeline completed at:" $(date)
```

Submitted batch job 61525897. Got this error after a few mins: 

```

Loading apptainer version latest
WARNING: While bind mounting '/scratch4:/scratch4': destination is already in the mount point list
ERROR in file /opt/BRAKER/scripts/braker.pl at line 6008
Failed to create new species with new_species.pl, check write permissions in /opt/Augustus/config//species directory! Command was /usr/bin/perl /opt/Augustus/scripts/new_species.pl --species=Sp_
1 --AUGUSTUS_CONFIG_PATH=/opt/Augustus/config/ 1> /dev/null 2>/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/errors/new_species.stderr
```

Some issue with reading and writing to different directories. Asked Gemini and it told me to write the config folder outside of the read-only container. 

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=150GB                
#SBATCH -t 48:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o braker_run-%j.out
#SBATCH -e braker_run-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Starting BRAKER3 Annotation Pipeline at:" $(date)

module load apptainer/latest

# ----------------------------------------------------
# Define Input and Output Paths
# ----------------------------------------------------
GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Ptua_hifiasm_s55.p_ctg.fa.k32.w100.z1000.ntLink.5rounds.fa.masked"
PROTEINS="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/protein_seqs/final_proteins_for_braker.fa"
OUT_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output"
SIF_IMAGE="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3.sif"

# Comma-separated BAMs list
BAM_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/rna_bams"
BAM_FILES="${BAM_DIR}/POC-201-TP1.sorted.bam,${BAM_DIR}/POC-201-TP2.sorted.bam,${BAM_DIR}/POC-201-TP3.sorted.bam,${BAM_DIR}/POC-219-TP1.sorted.bam,${BAM_DIR}/POC-219-TP2.sorted.bam,${BAM_DIR}/POC-219-TP3.sorted.bam,${BAM_DIR}/POC-219-TP4.sorted.bam,${BAM_DIR}/POC-222-TP1.sorted.bam,${BAM_DIR}/POC-222-TP2.sorted.bam,${BAM_DIR}/POC-222-TP3.sorted.bam,${BAM_DIR}/POC-222-TP4.sorted.bam,${BAM_DIR}/POC-255-TP1.sorted.bam,${BAM_DIR}/POC-255-TP2.sorted.bam,${BAM_DIR}/POC-255-TP3.sorted.bam,${BAM_DIR}/POC-255-TP4.sorted.bam,${BAM_DIR}/POC-259-TP1.sorted.bam,${BAM_DIR}/POC-259-TP2.sorted.bam,${BAM_DIR}/POC-259-TP3.sorted.bam,${BAM_DIR}/POC-259-TP4.sorted.bam,${BAM_DIR}/POC-40-TP1.sorted.bam,${BAM_DIR}/POC-40-TP2.sorted.bam,${BAM_DIR}/POC-40-TP3.sorted.bam,${BAM_DIR}/POC-40-TP4.sorted.bam,${BAM_DIR}/POC-42-TP1.sorted.bam,${BAM_DIR}/POC-42-TP2.sorted.bam,${BAM_DIR}/POC-42-TP3.sorted.bam,${BAM_DIR}/POC-42-TP4.sorted.bam,${BAM_DIR}/POC-52-TP1.sorted.bam,${BAM_DIR}/POC-52-TP2.sorted.bam,${BAM_DIR}/POC-52-TP3.sorted.bam,${BAM_DIR}/POC-52-TP4.sorted.bam,${BAM_DIR}/POC-53-TP1.sorted.bam,${BAM_DIR}/POC-53-TP2.sorted.bam,${BAM_DIR}/POC-53-TP3.sorted.bam,${BAM_DIR}/POC-53-TP4.sorted.bam,${BAM_DIR}/POC-57-TP1.sorted.bam,${BAM_DIR}/POC-57-TP2.sorted.bam,${BAM_DIR}/POC-57-TP3.sorted.bam,${BAM_DIR}/POC-57-TP4.sorted.bam"

# ----------------------------------------------------
# FIX: Extract and isolate Augustus Config onto Scratch
# ----------------------------------------------------
MY_AUG_CONFIG="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/augustus_config"

if [ ! -d "$MY_AUG_CONFIG" ]; then
    echo "Extracting Augustus config directory from container..."
    # Throws the config directory from inside the image to your writable scratch space
    apptainer exec ${SIF_IMAGE} cp -r /opt/Augustus/config "$MY_AUG_CONFIG"
    chmod -R 755 "$MY_AUG_CONFIG"
fi

# Export environment variable for the container to register
export AUGUSTUS_CONFIG_PATH="$MY_AUG_CONFIG"

# Set up Apptainer Cache
export APPTAINER_CACHEDIR=/scratch4/workspace/jillashey_uri_edu-Ptua_genome/.apptainer_cache
export APPTAINER_TMPDIR=/scratch4/workspace/jillashey_uri_edu-Ptua_genome/.apptainer_cache
mkdir -p $APPTAINER_CACHEDIR

# ----------------------------------------------------
# Run BRAKER3
# ----------------------------------------------------
# Added --AUGUSTUS_CONFIG_PATH flag to explicitly force the pipeline to use your scratch copy
apptainer exec -B /work,/scratch4,${MY_AUG_CONFIG}:/opt/Augustus/config ${SIF_IMAGE} \
    braker.pl \
    --genome=${GENOME} \
    --bam=${BAM_FILES} \
    --prot_seq=${PROTEINS} \
    --workingdir=${OUT_DIR} \
    --threads=${SLURM_CPUS_PER_TASK} \
    --AUGUSTUS_CONFIG_PATH=${MY_AUG_CONFIG} \
    --gff3

echo "BRAKER3 pipeline completed at:" $(date)
```

Submitted batch job 61525956

I SHOULD HAVE RENAMED THE CONTIGS HERE UGHHHHHHHHHHHHHHH--should i stop it??? idk gonna let it run and see how long it takes. but would be good to rename the contigs at this step so that the structural annotation can have that info


```
got this error: 
ERROR in file /opt/BRAKER/scripts/braker.pl at line 5578
Failed to execute: /usr/bin/perl /opt/ETP/bin/gmetp.pl --cfg /scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/GeneMark-ETP/etp_config.yaml --workdir /scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/GeneMark-ETP --bam /scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/GeneMark-ETP/etp_data/ --cores 24 --softmask  1>/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/errors/GeneMark-ETP.stdout 2>/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/errors/GeneMark-ETP.stderr
Failed to execute: /usr/bin/perl /opt/ETP/bin/gmetp.pl --cfg /scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/GeneMark-ETP/etp_config.yaml --workdir /scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/GeneMark-ETP --bam /scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/GeneMark-ETP/etp_data/ --cores 24 --softmask  1>/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/errors/GeneMark-ETP.stdout 2>/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/errors/GeneMark-ETP.stderr
The most common problem is that GeneMark-ETP didn't receive enough evidence from the input data, in this case, see errors/GeneMark-ETP.stderr!

# head from GeneMark-ETP.stderr
FASTA index file /scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/GeneMark-ETP/data/genome.softmasked.fasta.fai created.
Warning: couldn't find fasta record for 'Pocillopora_meandrina_HIv1___Sc0000000'!
Error: no genomic sequence available (check -g option!).
WARNING: 'Pocillopora_meandrina_HIv1___Sc0000000' does not match any sequence in the fasta file. Maybe the two files do not belong together.
WARNING: 'Pocillopora_meandrina_HIv1___Sc0000034' does not match any sequence in the fasta file. Maybe the two files do not belong together.
WARNING: 'Pocillopora_meandrina_HIv1___Sc0000013' does not match any sequence in the fasta file. Maybe the two files do not belong together.
WARNING: 'Pocillopora_meandrina_HIv1___Sc0000008' does not match any sequence in the fasta file. Maybe the two files do not belong together.

# head from GeneMark-ETP.stdout
warning, stop codon found in protein sequence, record Pver_g139.t2
warning, stop codon found in protein sequence, record Pver_g216.t1
warning, stop codon found in protein sequence, record Pver_g281.t2
warning, stop codon found in protein sequence, record Pver_g450.t1
warning, stop codon found in protein sequence, record Pver_g596.t1
```

ahhhh i need to align the fastq files with the Ptua genome duh...okay do that tomorrow

Download the trimmed fastq files for the POC samples 

```
wget --mirror --page-requisites --no-parent --no-host-directories --cut-dirs=5 \
     --accept "fastq.gz,fastq,fq.gz,fq" \
     https://gannet.fish.washington.edu/gitrepos/urol-e5/timeseries_molecular/F-Ptua/output/01.00-F-Ptua-RNAseq-trimming-fastp-FastQC-MultiQC/
```

Rename the soft-masked genome file and the chromosome names. `nano rename_genome.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1        
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=50GB                
#SBATCH -t 12:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked

# Define your file variables
OLD_GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Ptua_hifiasm_s55.p_ctg.fa.k32.w100.z1000.ntLink.5rounds.fa.masked"
NEW_GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Pocillopora_tuahiniensis_genome_v1.0.fasta"
MAP_FILE="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/scaffold_name_map.txt"

# Run AWK to rename the headers and generate the mapping file simultaneously
awk '
BEGIN { count = 1 } 
/^>/ { 
    old_name = substr($1, 2); 
    new_name = "Pocillopora_tuahiniensis_scaffold" count; 
    print old_name "\t" new_name > "'"$MAP_FILE"'"; 
    print ">" new_name; 
    count++; 
    next 
} 
{ print }
' "$OLD_GENOME" > "$NEW_GENOME"
```

Align the fastq files to the Ptua genome with hisat2. `nano hisat2.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=100GB                
#SBATCH -t 48:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

module purge

# Load modules
module load uri/main
module load all/HISAT2/2.2.1-gompi-2022a
module load all/SAMtools/1.18-GCC-12.3.0

GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Pocillopora_tuahiniensis_genome_v1.0.fasta"
INDEX="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Ptua_ref"
FASTQ_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/rna_fastq"
BAM_OUT_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/rna_bams"

# Ensure output directory exists
mkdir -p ${BAM_OUT_DIR}

echo "Building genome reference:" $(date)
# Build HISAT2 index using your variables
hisat2-build -f ${GENOME} ${INDEX}
echo "Reference genome indexed. Starting alignment:" $(date)

# Move into the fastq directory to easily process files
cd ${FASTQ_DIR}

# Loop through all Forward (R1) files
for r1_file in *_R1_*.fq.gz; do    
    sample_name=$(echo "${r1_file}" | awk -F "_R1_" '{print $1}')    
    r2_file=$(echo "${r1_file}" | sed 's/_R1_/_R2_/')
    
    echo "Processing sample: ${sample_name} at $(date)"    
    hisat2 -p 24 \
   			 --rna-strandness RF \
           --dta \
           -x ${INDEX} \
           -1 ${r1_file} \
           -2 ${r2_file} \
           --summary-file ${BAM_OUT_DIR}/${sample_name}_align_stats.txt \
           -S ${BAM_OUT_DIR}/${sample_name}.sam
    echo "Sorting and converting ${sample_name} to BAM..."
    samtools sort -@ 24 \
                  -o ${BAM_OUT_DIR}/${sample_name}.sorted.bam \
                  ${BAM_OUT_DIR}/${sample_name}.sam    
    samtools index ${BAM_OUT_DIR}/${sample_name}.sorted.bam
    rm ${BAM_OUT_DIR}/${sample_name}.sam
    echo "Sample ${sample_name} alignment complete!"
    echo "----------------------------------------"
done

echo "All alignments complete at:" $(date)
```

Submitted batch job 61591491. Running stranded so I can annotate UTRs. 

Merge bam files. `merge_bams.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=100GB                
#SBATCH -t 48:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

module purge

# Load modules
module load uri/main
module load all/SAMtools/1.18-GCC-12.3.0

BAM_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/rna_bams"
# Move into the fastq directory to easily process files
cd ${FASTQ_DIR}

echo "Merge bam files" $(date)
samtools merge Ptua_RNAseqAll.bam *sorted.bam 

echo "Merge complete" $(date)
```

Submitted batch job 61728578

Now that's done, I can start braker again. `nano braker3.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=150GB                
#SBATCH -t 72:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Starting BRAKER3 Stranded UTR Annotation Pipeline at:" $(date)

module load apptainer/latest

# ----------------------------------------------------
# Define Input and Output Paths
# ----------------------------------------------------
GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Pocillopora_tuahiniensis_genome_v1.0.fasta"
PROTEINS="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/protein_seqs/final_proteins_for_braker.fa"
OUT_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output"
SIF_IMAGE="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3.sif"

# Your newly merged master BAM file
BAM_FILE="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/rna_bams/Ptua_RNAseqAll.bam"

# ----------------------------------------------------
# Setup Augustus Writeable Configuration Space
# ----------------------------------------------------
MY_AUG_CONFIG="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/augustus_config"
if [ ! -d "$MY_AUG_CONFIG" ]; then
    apptainer exec ${SIF_IMAGE} cp -r /opt/Augustus/config "$MY_AUG_CONFIG"
    chmod -R 755 "$MY_AUG_CONFIG"
fi

export AUGUSTUS_CONFIG_PATH="$MY_AUG_CONFIG"
#export JAVA_PATH="/usr/bin"
export APPTAINER_CACHEDIR=/scratch4/workspace/jillashey_uri_edu-Ptua_genome/.apptainer_cache
export APPTAINER_TMPDIR=/scratch4/workspace/jillashey_uri_edu-Ptua_genome/.apptainer_cache

# Wiping previous outputs to ensure fresh model training
rm -rf ${OUT_DIR}
mkdir -p ${OUT_DIR}

# ----------------------------------------------------
# Run BRAKER3 with Full UTR Training
# ----------------------------------------------------
apptainer exec -B /work,/scratch4,${MY_AUG_CONFIG}:/opt/Augustus/config ${SIF_IMAGE} \
    braker.pl \
    --species=Pocillopora_tuahiniensis \
    --genome=${GENOME} \
    --bam=${BAM_FILE} \
    --prot_seq=${PROTEINS} \
    --workingdir=${OUT_DIR} \
    --threads=${SLURM_CPUS_PER_TASK} \
    --AUGUSTUS_CONFIG_PATH=${MY_AUG_CONFIG} \
    #--JAVA_PATH=${JAVA_PATH} \
    --busco_lineage=metazoa_odb10 \
    --UTR=on \
    --gff3

echo "BRAKER3 pipeline completed at:" $(date)
```

Submitted batch job 61757302.

Count number of features identified

```
awk '/^[^#]/ {print $3}' braker.gtf | sort | uniq -c

 245825 CDS
 245825 exon
  27217 gene
 213122 intron
   3038 mRNA
  32650 start_codon
  32660 stop_codon
  32703 transcript
  
awk '/^[^#]/ {print $2}' braker.gtf | sort | uniq -c
 686589 AUGUSTUS
  55232 GeneMark.hmm3
  91219 gmst
  
grep -c ">" braker.aa
32703

grep -c ">" braker.codingseq
32703
```

Calculate average protein length 

```
awk '/^>/ {if (seqlen) {sum+=seqlen; count++}; seqlen=0; next} {seqlen+=length($0)} END {if (seqlen) {sum+=seqlen; count++}; print "Average Protein Length: " sum/count " AA"}' braker.aa
Average Protein Length: 505.544 AA
```

Calculate average gene length

```
awk '$3 == "transcript" || $3 == "mRNA" {sum += ($5 - $4 + 1); count++} END {print "Average Gene Genomic Length: " sum/count " bp"}' braker.gff3
Average Gene Genomic Length: 5897.75 bp
```

Calculate mean number of exons per gene

```
awk 'BEGIN {print "Mean Exons per Gene: " 245825 / 27217}'
Mean Exons per Gene: 9.03204
```

Calculate average exon length 

```
awk '$3 == "exon" {sum += ($5 - $4 + 1); count++} END {if (count > 0) print "Mean Exon Length: " sum/count " bp"}' braker.gff3
Mean Exon Length: 201.763 bp
```

Calculate mean number of introns per gene

```
awk 'BEGIN {print "Mean Introns per Gene: " 213122 / 27217}'
Mean Introns per Gene: 7.83047
```

Calculate average intron length 

```
awk '$3 == "intron" {sum += ($5 - $4 + 1); count++} END {if (count > 0) print "Mean Intron Length: " sum/count " bp"}' braker.gtf
Mean Intron Length: 672.271 bp
```


Run tRNAscan-se to identify tRNAs. `nano trnascan.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=100GB                
#SBATCH -t 48:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Starting tRNAscan-SE Analysis at:" $(date)

module load conda/latest # need to load before making any conda envs
conda activate /work/pi_hputnam_uri_edu/conda/envs/trnascan

# Define your paths
GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Pocillopora_tuahiniensis_genome_v1.0.fasta"
OUT_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/trnascan_output"

mkdir -p ${OUT_DIR}

tRNAscan-SE -E \
            --threads ${SLURM_CPUS_PER_TASK} \
            -o ${OUT_DIR}/Ptua-tRNA.out \
            -f ${OUT_DIR}/Ptua-tRNA_struct.out \
            -m ${OUT_DIR}/Ptua-tRNA_stats.out \
            -j ${OUT_DIR}/Ptua-tRNA.gff3 \
            -a ${OUT_DIR}/Ptua-tRNA.fasta \
            -d \
            ${GENOME}

conda deactivate

echo "tRNAscan analysis complete" $(date)
```

Submitted batch job 61729456.

Count number of tRNAs identified

```
cd /scratch4/workspace/jillashey_uri_edu-Ptua_genome/trnascan_output

awk '/^[^#]/ {print $3}' Ptua-tRNA.gff3 | sort | uniq -c
   4079 exon
   1725 pseudogene
   2271 tRNA
```

2271 tRNAs identified. 

Run barrnap to identify rRNAs. `nano barrnap.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=100GB                
#SBATCH -t 48:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Starting barrnap Analysis at:" $(date)

module load conda/latest # need to load before making any conda envs
conda activate /work/pi_hputnam_uri_edu/conda/envs/barrnap

GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Pocillopora_tuahiniensis_genome_v1.0.fasta"
OUT_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/barrnap_output"

mkdir -p ${OUT_DIR}

barrnap --kingdom euk \
        --threads ${SLURM_CPUS_PER_TASK} \
        --outseq ${OUT_DIR}/Ptua_rRNA.fa \
        ${GENOME} > ${OUT_DIR}/Ptua_rRNA.gff3

echo "barrnap complete" $(date)
conda deactivate
```

Submitted batch job 61728863

Count how many rRNAs were identifed

```
awk '$3 == "rRNA"' Ptua_rRNA.gff3 | wc -l
```

122 rRNAs identified. 

Cat gff3s together for full structural annotation. `nano cat_gff3.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=100GB                
#SBATCH -t 48:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Cat GFFs" $(date)

cat braker3_output/braker.gff3 \
    trnascan_output/Ptua-tRNA.gff3 \
    barrnap_output/Ptua_rRNA.gff3 \
    > Pocillopora_tuahiniensis_genome_v1.0.master.gff3
    
echo "Cat complete" $(date)
``` 

Submitted batch job 61906099

Uploaded genome to NCBI
- BioProject: PRJNA1496434
- Biosample: SAMN61716200
- Locus tag prefixes: AC51O9

## functional annotation

Eggnog. `nano eggnog.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=100GB                
#SBATCH -t 48:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Starting EggNOG-mapper analysis at:" $(date)

# Load environmental modules
module load uri/main
module load all/eggnog-mapper/2.1.9-foss-2022a

# Define Paths
PROT_FASTA="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/braker.aa"
OUT_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/func_anno"

# Run EggNOG-mapper
emapper.py \
    -i ${PROT_FASTA} \
    -o ${OUT_DIR}/Ptua_eggnog \
    --data_dir /datasets/bio/eggnog5-data/ \
    -m diamond \
    --sensmode sensitive \
    --cpu ${SLURM_CPUS_PER_TASK} \
    --override

echo "EggNOG-mapper analysis completed at:" $(date)
```

Submitted batch job 61884709

Run interproscan. `nano interproscan.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=100GB                
#SBATCH -t 120:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Starting InterProScan analysis at:" $(date)

# Load modules
module load uri/main
module load all/InterProScan/5.73-104.0-foss-2024a

# Remove asterisks 
sed 's/\*//g' /scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/braker.aa > /scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/braker_clean.aa

# Define paths
PROT_FASTA="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/braker_clean.aa"
OUT_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/func_anno"

#mkdir -p ${OUT_DIR}

# Run interproscan
interproscan.sh \
    -i ${PROT_FASTA} \
    -b ${OUT_DIR}/Ptua_iprscan \
    -f XML \
    -goterms \
    -pa \
    -cpu ${SLURM_CPUS_PER_TASK}

echo "InterProScan analysis completed at:" $(date)
```

Submitted batch job 61905140 

Run funannotate to merge the functional annotations. `funannotate_merge.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=100GB                
#SBATCH -t 120:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Install  funannotate" $(date)

# load modules 
module load conda/latest 

# Install 
conda activate base
conda create -p /work/pi_hputnam_uri_edu/conda/envs/funannotate -c conda-forge -c bioconda funannotate python=3.8 -y
conda activate /work/pi_hputnam_uri_edu/conda/envs/funannotate

echo "Installation complete, automate funannotate db path" $(date)

# Create the environment hook directories
mkdir -p /work/pi_hputnam_uri_edu/conda/envs/funannotate/etc/conda/activate.d
mkdir -p /work/pi_hputnam_uri_edu/conda/envs/funannotate/etc/conda/deactivate.d

# Write the export/unset rules to the hooks
echo "export FUNANNOTATE_DB=/work/pi_hputnam_uri_edu/funannotate_db" >> /work/pi_hputnam_uri_edu/conda/envs/funannotate/etc/conda/activate.d/funannotate.sh
echo "unset FUNANNOTATE_DB" >> /work/pi_hputnam_uri_edu/conda/envs/funannotate/etc/conda/deactivate.d/funannotate.sh

# Reactivate the environment to apply the change instantly
conda activate /work/pi_hputnam_uri_edu/conda/envs/funannotate
conda deactivate 

conda activate /work/pi_hputnam_uri_edu/conda/envs/funannotate
echo "Download and format dbs" $(date)
mkdir -p /scratch4/workspace/jillashey_uri_edu-Ptua_genome/funannotate_db
funannotate setup -d /scratch4/workspace/jillashey_uri_edu-Ptua_genome/funannotate_db -b metazoa --wget
funannotate check --show-versions

echo "Merge functional annotations" $(date)
#source $(conda info --base)/etc/profile.d/conda.sh
#conda activate /work/pi_hputnam_uri_edu/conda/envs/funannotate

# Define file paths 
GENOME_FASTA="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Pocillopora_tuahiniensis_genome_v1.0.fasta"  
BRAKER_GFF="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output/braker.gff3"
EGGNOG_ANNO="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/func_anno/Ptua_eggnog.emapper.annotations"
IPRSCAN_XML="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/func_anno/Ptua_iprscan.xml"
OUT_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/funannotate_output"

mkdir -p ${OUT_DIR}

funannotate annotate --gff ${BRAKER_GFF} --fasta ${GENOME_FASTA} -s "Pocillopora tuahiniensis" --busco_db metazoa --eggnog ${EGGNOG_ANNO} --iprscan ${IPRSCAN_XML} --cpus ${SLURM_CPUS_PER_TASK} -o ${OUT_DIR}

echo "Functional annotation merge complete" $(date)
```

Submitted batch job 61941803

and blobtools 

```
module load conda/latest 
#conda activate base

conda create -p /work/pi_hputnam_uri_edu/conda/envs/blobtools -c conda-forge -c bioconda blobtoolkit firefox geckodriver -y
```

# Starting over???

Okay we are really starting from square 1 here. I NEED TO DO THE FOLLOWING. I tried uploading the genome to ncbi but it came back with contaminant hits. after asking AIs, it told me to: 

- Clean Adapters: Run hiFiAdapterFilt on raw HiFi reads. https://github.com/sheinasim-USDA/HiFiAdapterFilt/blob/master/hifiadapterfilt.sh
- Assemble nuclear: Run hifiasm on the cleaned reads (utilizing its internal purge). IF NEEDED: https://github.com/dfguan/purge_dups
- Assemble mito 
- Decontaminate Contigs: Run FCS-GX on the primary contigs to strip out remaining Symbiodiniaceae and bacterial scaffolds. https://github.com/ncbi/fcs-gx. https://github.com/ncbi/fcs/wiki/FCS-GX-quickstart
- Check Duplication: Run BUSCO. (Optional: run standalone purge_dups only if duplicate stats are high).
- Scaffold: Run nt-links on the cleaned, deduplicated primary host contigs.
- rename genome contigs
- Run BUSCO/Quast on scaffolded genome 
- repeat modeler 
- repeat masker 
- braker3
- trnascan 
- barrnap
- funannotate (or follow whatever the porites harrisoni did)

maybe make plot showing raw reads and filtered reads???

## Clean adapters 

Let's remove the adapters first using [hiFiAdapterFilt](https://github.com/sheinasim-USDA/HiFiAdapterFilt/) on raw HiFi reads. Install. 

```
module load conda/latest 
conda create -p /work/pi_hputnam_uri_edu/conda/envs/hifiadapterfilt -c conda-forge -c bioconda blast bamtools samtools fastp coreutils -y
conda activate /work/pi_hputnam_uri_edu/conda/envs/hifiadapterfilt

mkdir -p /work/pi_hputnam_uri_edu/conda/tools
cd /work/pi_hputnam_uri_edu/conda/tools
git clone https://github.com/sheinasim-USDA/HiFiAdapterFilt.git
chmod +x /work/pi_hputnam_uri_edu/conda/tools/HiFiAdapterFilt/hifiadapterfilt.sh
```

Remove adapters. `nano remove_hifi_adapters.sh`

```
#!/usr/bin/env bash
#SBATCH --export=ALL
#SBATCH --ntasks=1 --cpus-per-task=24
#SBATCH --partition=uri-cpu,cpu,cpu-preempt
#SBATCH --no-requeue
#SBATCH --mem=100GB
#SBATCH -t 24:00:00
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

# Load environment
module load conda/latest
conda activate /work/pi_hputnam_uri_edu/conda/envs/hifiadapterfilt

# Export tool and DB paths into PATH
export PATH="/work/pi_hputnam_uri_edu/conda/tools/HiFiAdapterFilt:$PATH"
export PATH="/work/pi_hputnam_uri_edu/conda/tools/HiFiAdapterFilt/DB:$PATH"

# Setup working and output directories
WORK_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome"
OUT_DIR="${WORK_DIR}/adapter_filtered"
mkdir -p ${OUT_DIR}

cd ${WORK_DIR}

# Ensure input FASTQ is symlinked in current directory
ln -sf /work/pi_hputnam_uri_edu/Ptua_genome/Ptua_hifi_reads.fastq.gz .

echo "Starting adapter removal:" $(date)

# Execute via full path
bash /work/pi_hputnam_uri_edu/conda/tools/HiFiAdapterFilt/hifiadapterfilt.sh \
  -p Ptua_hifi_reads \
  -t 24 \
  -o ${OUT_DIR}

echo "Adapter removal complete:" $(date)
```

Submitted batch job 63132086

check how many reads so far. `nano read_check.sh`

```
awk '/^>/ { if (seq) {print header"\t"length(seq)}; header=substr($0,2); seq="" ; next } 
     {seq=seq$0} 
     END {print header"\t"length(seq)}' Ptua_hifi_reads.fasta > Ptua_rr_read_lengths.txt

echo "Read length summary complete" $(date)
```

okay this keeps stalling out. going back to just removing the contam reads and then will run fsc-gx after assembly (and maybe blobtoolkit). need to rerun all the blast again because i deleted the files because im dumb. Here are the jobs:

- viral = 63185360
- euk = 63185410
- prok = 63185495
- sym = 63185530
- mito = 63185557


## Assembly of nuclear genome 

Run on adapter-filtered data. Submitted batch job 63185864

Convert gfa to fasta. 

```
awk '/^S/{print ">"$2"\n"$3}' Ptua_hifiasm.p_ctg.gfa | fold > Ptua_primary.fasta
grep -c ">" Ptua_primary.fasta
3454
```

## FCS-GX 

Install 

```
module load apptainer/latest

mkdir -p /work/pi_hputnam_uri_edu/conda/tools/fcs_gx
cd /work/pi_hputnam_uri_edu/conda/tools/fcs_gx

# Download runner script
curl -LO https://github.com/ncbi/fcs/raw/main/dist/fcs.py
chmod +x fcs.py

# Download the official Apptainer/Singularity container image
curl https://ftp.ncbi.nlm.nih.gov/genomes/TOOLS/FCS/releases/latest/fcs-gx.sif -Lo fcs-gx.sif
export FCS_DEFAULT_IMAGE=fcs-gx.sif
```

Download fcs-gx db. `nano download_fcs_db.sh`

```
#!/usr/bin/env bash
#SBATCH --job-name=download_fcs_db
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --mem=32GB
#SBATCH -t 12:00:00
#SBATCH -o download_db_%j.out
#SBATCH -e download_db_%j.err

# Load Apptainer or Singularity
module load apptainer 2>/dev/null || module load singularity 2>/dev/null

cd /work/pi_hputnam_uri_edu/conda/tools/fcs_gx

export FCS_DEFAULT_IMAGE=fcs-gx.sif
export NCBI_FCS_REPORT_ANALYTICS=0

LOCAL_DB="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/fcs_gx_db"
SOURCE_DB_MANIFEST="https://ncbi-fcs-gx.s3.amazonaws.com/gxdb/latest/all.manifest"

echo "Starting FCS-GX database download..." $(date)

# Download database
python3 fcs.py db get --mft "$SOURCE_DB_MANIFEST" --dir "$LOCAL_DB/gxdb"

# Check integrity
python3 fcs.py db check --mft "$SOURCE_DB_MANIFEST" --dir "$LOCAL_DB/gxdb"

echo "Download and verification complete!" $(date)
```

Submitted batch job 63028548.

Run the fcs-gx screen on the assembled data. `nano fcs_gx_screen.sh`

```
#!/usr/bin/env bash
#SBATCH --job-name=fcs_gx_screen
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --partition=uri-gpu
#SBATCH --gres=gpu:1
#SBATCH --mem=500GB
#SBATCH -t 24:00:00
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

# Load Apptainer module
module load apptainer/latest 
module load conda/latest

# Go to location 
cd /scratch4/workspace/jillashey_uri_edu-Ptua_genome

# Environment Setup
export PATH="/work/pi_hputnam_uri_edu/conda/tools/fcs_gx:$PATH"
export FCS_DEFAULT_IMAGE="/work/pi_hputnam_uri_edu/conda/tools/fcs_gx/fcs-gx.sif"
export NCBI_FCS_REPORT_ANALYTICS=0

# Path Variables
LOCAL_DB="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/fcs_gx_db/gxdb"
ASSEMBLY="Ptua_primary.fasta"
OUTDIR="fcs_gx_output"
TAX_ID="3041103" # NCBI taxon ID for Ptua

echo "Starting FCS-GX Screening:" $(date)

# Run FCS-GX Screen
python3 /work/pi_hputnam_uri_edu/conda/tools/fcs_gx/fcs.py screen genome \
    --fasta "$ASSEMBLY" \
    --out-dir "$OUTDIR" \
    --gx-db "$LOCAL_DB" \
    --tax-id "$TAX_ID"

echo "FCS-GX Screening Complete:" $(date)
```

Submitted batch job 63260007. Look at output

```
wc -l *
   1517 Ptua_primary.3041103.fcs_gx_report.txt
   3549 Ptua_primary.3041103.taxonomy.rpt
   
head Ptua_primary.3041103.fcs_gx_report.txt
##[["FCS genome report", 2, 1], {"git-rev": "v0.5.5-0-g0bda491", "run-date": "Wed Aug 19 18:41:53 2026", "db": {"build-date": "2023-01-24", "seqs": 3025824, "Gbp": 709.264}, "run-info": {"agg-cvg": 0.914332, "a
sserted-div": "anml:basal metazoans", "inferred-primary-divs": ["anml:basal metazoans"], "corrected-primary-divs": ["anml:basal metazoans"], "genome-hash": "c2b2b0c34dfe2c91"}}]
#seq_id start_pos       end_pos seq_len action  div     agg_cont_cov    top_tax_name
ptg000035l      1       17191   17191   EXCLUDE prst:alveolates 100     Cladocopium goreaui
ptg000052l      1       22417   22417   EXCLUDE prst:alveolates 97      Cladocopium goreaui
ptg000061l      1       12330   12330   EXCLUDE prst:alveolates 98      Cladocopium goreaui
ptg000087l      1       32084   32084   EXCLUDE prst:alveolates 100     Cladocopium goreaui
ptg000093l      1       16701   16701   EXCLUDE prst:alveolates 92      Cladocopium goreaui
ptg000100l      1       37907   37907   EXCLUDE prst:alveolates 100     Cladocopium goreaui
ptg000117l      1       24483   24483   EXCLUDE prst:alveolates 100     Cladocopium goreaui
ptg000120l      1       16286   16286   EXCLUDE prst:alveolates 93      Cladocopium goreaui

head Ptua_primary.3041103.taxonomy.rpt
##[["GX taxonomy analysis report", 3, 1], {"git-rev": "v0.5.5-0-g0bda491", "run-date": "Wed Aug 19 18:41:53 2026", "db": {"build-date": "2023-01-24", "seqs": 3025824, "Gbp": 709.264}, "run-info": {"agg-cvg": 0.
914332, "asserted-div": "anml:basal metazoans", "inferred-primary-divs": ["anml:basal metazoans"], "corrected-primary-divs": ["anml:basal metazoans"], "genome-hash": "c2b2b0c34dfe2c91"}}]
#seq-id seq-len (xp,lc,co,n,mt,pt,pm)-len       cvg-by-all      sep1    tax-name-1      tax-id-1        div-1   cvg-by-div-1    cvg-by-tax-1    score-1 sep2    tax-id-2        div-2   cvg-by-div-2    cvg-by-tax
-2      score-2 sep3    tax-id-3        div-3   cvg-by-div-3    cvg-by-tax-3    score-3 sep4    tax-id-4        div-4   cvg-by-div-4    cvg-by-tax-4    score-4 sep5    reserved        result  div     div_pct_cv
g
ptg000001l      120232  7267,326,1060,0,0,0,0   115276  |       Pocillopora damicornis  46731   anml:basal metazoans    114829  109833  2311    |       50429   anml:basal metazoans    114829  96625   1076    |6
84658   anml:insects    9930    5107    108     |       41139   anml:insects    9930    3708    88      |       n/a     primary-div     anml:basal metazoans    96
ptg000002l      77629   2957,167,0,0,0,0,0      71135   |       Pocillopora damicornis  46731   anml:basal metazoans    70848   63634   1208    |       50429   anml:basal metazoans    70848   36503   511     |1
454006  prok:CFB group bacteria 2576    2576    54      |       3986    plnt:plants     2574    2110    52      |       n/a     primary-div     anml:basal metazoans    91
ptg000003l      885951  63461,9264,7820,0,0,0,0 855802  |       Pocillopora damicornis  46731   anml:basal metazoans    852803  828958  6141    |       50429   anml:basal metazoans    852803  600533  2298    |6
596     anml:molluscs   21941   6115    116     |       7574    anml:brachiopods        5314    5314    105     |       n/a     primary-div     anml:basal metazoans    96
ptg000004l      451498  93446,2848,180,0,0,0,0  333893  |       Pocillopora damicornis  46731   anml:basal metazoans    327871  204556  2217    |       50429   anml:basal metazoans    327871  227113  1294    |2
921223  anml:insects    6141    2740    59      |       189913  anml:insects    6141    1929    50      |       n/a     primary-div     anml:basal metazoans    73
ptg000005l      739090  45866,2924,3320,0,0,0,0 677102  |       Pocillopora damicornis  46731   anml:basal metazoans    674467  597413  5122    |       50429   anml:basal metazoans    674467  453398  2092    |3
2391    anml:insects    16989   4437    85      |       64838   anml:insects    16989   3709    82      |       n/a     primary-div     anml:basal metazoans    91
ptg000006l      168255  17602,5845,100,0,0,0,0  149031  |       Pocillopora damicornis  46731   anml:basal metazoans    148286  139992  1876    |       50429   anml:basal metazoans    148286  48523   510     |5
7068    anml:birds      1308    911     41      |       88015   anml:crustaceans        1521    1207    40      |       n/a     primary-div     anml:basal metazoans    88
ptg000007l      591912  34918,2822,780,0,0,0,0  543668  |       Pocillopora damicornis  46731   anml:basal metazoans    540007  474222  4594    |       50429   anml:basal metazoans    540007  363781  1739    |9
5602    anml:crustaceans        9351    6137    86      |       144034  anml:insects    8181    3798    79      |       n/a     primary-div     anml:basal metazoans    91
ptg000008l      507378  31855,1223,0,0,0,0,0    438064  |       Pocillopora damicornis  46731   anml:basal metazoans    433328  387819  3752    |       50429   anml:basal metazoans    433328  273718  1564    |2
138241  anml:nematodes  3610    3050    60      |       2607531 anml:molluscs   3713    2573    56      |       n/a     primary-div     anml:basal metazoans    85
```

Clean the contaminants. `nano fcs_gx_clean.sh`

```
#!/usr/bin/env bash
#SBATCH --export=ALL
#SBATCH --ntasks=1 --cpus-per-task=24
#SBATCH --partition=uri-cpu
#SBATCH --no-requeue
#SBATCH --mem=100GB
#SBATCH -t 24:00:00
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

# Load modules 
module load uri/main
module load seqtk/1.4-GCC-12.3.0

# Go to location 
cd /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Starting FCS-GX Cleaning:" $(date)

# Extract non-comment sequence IDs into a list of contigs to remove
grep -v "^#" fcs_gx_output/Ptua_primary.3041103.fcs_gx_report.txt | awk '{print $1}' | sort -u > contigs_to_remove.txt

# Make a list of all reads 
grep "^>" Ptua_primary.fasta | sed 's/^>//' > Ptua_primary.txt

# Make a list of filtered reads only 
grep -v -F -f contigs_to_remove.txt Ptua_primary.txt > filtered_contigs.txt

# Filter reads 
seqtk subseq -v Ptua_primary.fasta filtered_contigs.txt > Ptua_primary_clean.fasta

grep -c ">" Ptua_primary.fasta
grep -c ">" Ptua_primary_clean.fasta

echo "FCS-GX Cleaning Complete:" $(date)
```

Submitted batch job 63268839. Success! 

## ntlinks to further scaffold assembly 

`nano ntlinks.sh`

```
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
target= Ptua_primary_clean.fasta \
reads=/work/pi_hputnam_uri_edu/Ptua_genome/Ptua_hifi_reads.fastq.gz \
out_prefix=Ptua_primary_clean_ntlinks

echo "Scaffolding of hifiasm primary assembly with ntlinks (rounds = 5) complete!" $(date)
```

Submitted batch job 63271435.

Check out the output: 

```
grep -c ">" Ptua_primary_clean.fasta.k32.w100.z1000.ntLink.gap_fill.5rounds.fa
1137
```

## Polish with minimap2 and racon 

`nano racon_polish.sh`

```
#!/usr/bin/env bash
#SBATCH --export=ALL
#SBATCH --ntasks=1 --cpus-per-task=24
#SBATCH --partition=uri-cpu,cpu,cpu-preempt
#SBATCH --no-requeue
#SBATCH --mem=200GB
#SBATCH -t 24:00:00
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

# Load modules 
module load uri/main 
module load all/Racon/1.5.0-GCCcore-12.3.0 
module load all/minimap2/2.26-GCCcore-12.3.0

echo "Aligning raw reads to scaffolded assembly" $(date)
minimap2 -x map-hifi -t 36 \
    Ptua_primary_clean.fasta.k32.w100.z1000.ntLink.gap_fill.5rounds.fa \
    /work/pi_hputnam_uri_edu/Ptua_genome/Ptua_hifi_reads.fastq.gz \
    > ptua_ntlink_mapped.paf

echo "Alignment complete, polish" $(date)

# Polish filled gap regions
racon -t 36 \
    /work/pi_hputnam_uri_edu/Ptua_genome/Ptua_hifi_reads.fastq.gz \
    ptua_ntlink_mapped.paf \
    Ptua_primary_clean.fasta.k32.w100.z1000.ntLink.gap_fill.5rounds.fa \
    > Ptua_polished.fasta

echo "Polishing complete!" $(date)

rm ptua_ntlink_mapped.paf
```

Submitted batch job 63355430. Check output: 

```
grep -c ">" Ptua_polished.fasta
1137
```

## change scaffold names and clean with funannotate 

Prep genome for annotation with funannotate. `nano clean_sort_genome.sh`

```
#!/usr/bin/env bash
#SBATCH --export=ALL
#SBATCH --ntasks=1 --cpus-per-task=24
#SBATCH --partition=uri-cpu,cpu,cpu-preempt
#SBATCH --no-requeue
#SBATCH --mem=200GB
#SBATCH -t 24:00:00
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

module load conda/latest
conda activate /work/pi_hputnam_uri_edu/conda/envs/funannotate

echo "Remove duplicates and short contigs" $(date)

funannotate clean -i Ptua_polished.fasta -o Ptua_cleaned.fasta --exhaustive 

echo "Cleaning complete" $(date)

conda deactivate
```

Submitted batch job 63364442

## Rename genome 


Rename the soft-masked genome file and the chromosome names. `nano rename_genome.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1        
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=50GB                
#SBATCH -t 12:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

# Define your file variables
OLD_GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/Ptua_cleaned.fasta"
NEW_GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/Pocillopora_tuahiniensis_genome_v1.0.fasta"
MAP_FILE="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/scaffold_name_map.txt"

# Run AWK to rename the headers and generate the mapping file simultaneously
awk '
BEGIN { count = 1 } 
/^>/ { 
    old_name = substr($1, 2); 
    new_name = "Pocillopora_tuahiniensis_scaffold" count; 
    print old_name "\t" new_name > "'"$MAP_FILE"'"; 
    print ">" new_name; 
    count++; 
    next 
} 
{ print }
' "$OLD_GENOME" > "$NEW_GENOME"
```

Submitted batch job 63366857

## Quast and busco 

`nano quast.sh`

```
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
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

module load uri/main
module load QUAST/5.0.2-foss-2021b

echo "Begin quast of assembled genome" $(date)

quast --eukaryote \
Pocillopora_tuahiniensis_genome_v1.0.fasta \
Ptua_polished.fasta \
Ptua_primary_clean.fasta.k32.w100.z1000.ntLink.gap_fill.5rounds.fa \
Ptua_primary_clean.fasta \
Ptua_primary.fasta \
Pver_genome_assembly_v1.0.fasta \
/work/pi_hputnam_uri_edu/HI_Genomes/Pmeandrina/Pocillopora_meandrina_HIv1.assembly.fasta \
/work/pi_hputnam_uri_edu/HI_Genomes/PacutaV2/Pocillopora_acuta_HIv2.assembly.fasta \
-o quast

echo "Quast complete" $(date)
```

Submitted batch job 63367331

`nano busco.sh`

```
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
```

Submitted batch job 63367447. results: 

```
	***** Results: *****

	C:96.4%[S:91.3%,D:5.1%],F:0.8%,M:2.7%,n:954,E:4.3%	   
	920	Complete BUSCOs (C)	(of which 40 contain internal stop codons)		   
	871	Complete and single-copy BUSCOs (S)	   
	49	Complete and duplicated BUSCOs (D)	   
	8	Fragmented BUSCOs (F)			   
	26	Missing BUSCOs (M)			   
	954	Total BUSCO groups searched		   

Assembly Statistics:
	1137	Number of scaffolds
	1137	Number of contigs
	356090324	Total length
	0.000%	Percent gaps
	738 KB	Scaffold N50
	738 KB	Contigs N50
```


## repeat modeler

`nano repeatmodeler.sh`

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
```

Submitted batch job 63369032

## repeat masker 

`nano repeatmasker.sh`

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
	Pocillopora_tuahiniensis_genome_v1.0.fasta

echo "Repeatmasker complete" $(date)
```

Submitted batch job 63459474

## hisat2 

Align RNAseq reads to assembled genome for braker3 

`nano hisat2.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=uri-cpu
#SBATCH --no-requeue
#SBATCH --mem=100GB                
#SBATCH -t 48:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

# load modules needed
module purge 

# Load modules
module load uri/main
module load all/HISAT2/2.2.1-gompi-2022a
module load all/SAMtools/1.18-GCC-12.3.0

GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Pocillopora_tuahiniensis_genome_v1.0.fasta.masked"
INDEX="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Ptua_ref"
FASTQ_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/rna_fastq"
BAM_OUT_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/rna_bams"

# Ensure output directory exists
mkdir -p ${BAM_OUT_DIR}

echo "Building genome reference:" $(date)
# Build HISAT2 index using your variables
hisat2-build -f ${GENOME} ${INDEX}
echo "Reference genome indexed. Starting alignment:" $(date)

# Move into the fastq directory to easily process files
cd ${FASTQ_DIR}

# Loop through all Forward (R1) files
for r1_file in *_R1_*.fq.gz; do
    sample_name=$(echo "${r1_file}" | awk -F "_R1_" '{print $1}')
    r2_file=$(echo "${r1_file}" | sed 's/_R1_/_R2_/')
    echo "Processing sample: ${sample_name} at $(date)"
    hisat2 -p 24 \
   	   --rna-strandness RF \
           --dta \
           -x ${INDEX} \
           -1 ${r1_file} \
           -2 ${r2_file} \
           --summary-file ${BAM_OUT_DIR}/${sample_name}_align_stats.txt \
           -S ${BAM_OUT_DIR}/${sample_name}.sam
    echo "Sorting and converting ${sample_name} to BAM..."
    samtools sort -@ 24 \
                  -o ${BAM_OUT_DIR}/${sample_name}.sorted.bam \
                  ${BAM_OUT_DIR}/${sample_name}.sam
    samtools index ${BAM_OUT_DIR}/${sample_name}.sorted.bam
    rm ${BAM_OUT_DIR}/${sample_name}.sam
    echo "Sample ${sample_name} alignment complete!"
    echo "----------------------------------------"
done

echo "All alignments complete at:" $(date)
```

Submitted batch job 63477655


## Merge bams 

`nano merge_bams.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=100GB                
#SBATCH -t 48:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

module purge

# Load modules
module load uri/main
module load all/SAMtools/1.18-GCC-12.3.0

BAM_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/rna_bams"
# Move into the fastq directory to easily process files
cd ${BAM_DIR}

echo "Merge bam files" $(date)
samtools merge Ptua_RNAseqAll.bam *sorted.bam 

echo "Merge complete" $(date)
```

## braker3

`nano braker3.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=gpu
#SBATCH -G 1
#SBATCH --no-requeue
#SBATCH --mem=150GB                
#SBATCH -t 48:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Starting BRAKER3 Stranded UTR Annotation Pipeline at:" $(date)

#module load apptainer/latest

# Load modules
module load uri/main
module load all/SAMtools/1.18-GCC-12.3.0

BAM_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/rna_bams"
# Move into the fastq directory to easily process files
cd ${BAM_DIR}

echo "Merge bam files" $(date)
samtools merge Ptua_RNAseqAll.bam *sorted.bam 

echo "Merge complete" $(date)

module purge
module load apptainer/latest


# ----------------------------------------------------
# Define Input and Output Paths
# ----------------------------------------------------
GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Pocillopora_tuahiniensis_genome_v1.0.fasta.masked"
PROTEINS="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/protein_seqs/final_proteins_for_braker.fa"
OUT_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3_output"
SIF_IMAGE="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/braker3.sif"

# Your newly merged master BAM file
BAM_FILE="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/rna_bams/Ptua_RNAseqAll.bam"

# ----------------------------------------------------
# Setup Augustus Writeable Configuration Space
# ----------------------------------------------------
MY_AUG_CONFIG="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/augustus_config"
if [ ! -d "$MY_AUG_CONFIG" ]; then
    apptainer exec ${SIF_IMAGE} cp -r /opt/Augustus/config "$MY_AUG_CONFIG"
    chmod -R 755 "$MY_AUG_CONFIG"
fi

export AUGUSTUS_CONFIG_PATH="$MY_AUG_CONFIG"
#export JAVA_PATH="/usr/bin"
export APPTAINER_CACHEDIR=/scratch4/workspace/jillashey_uri_edu-Ptua_genome/.apptainer_cache
export APPTAINER_TMPDIR=/scratch4/workspace/jillashey_uri_edu-Ptua_genome/.apptainer_cache

# Wiping previous outputs to ensure fresh model training
rm -rf ${OUT_DIR}
mkdir -p ${OUT_DIR}

# ----------------------------------------------------
# Run BRAKER3 with Full UTR Training
# ----------------------------------------------------
apptainer exec -B /work,/scratch4,${MY_AUG_CONFIG}:/opt/Augustus/config ${SIF_IMAGE} \
    braker.pl \
    --genome=${GENOME} \
    --bam=${BAM_FILE} \
    --prot_seq=${PROTEINS} \
    --workingdir=${OUT_DIR} \
    --threads=${SLURM_CPUS_PER_TASK} \
    --AUGUSTUS_CONFIG_PATH=${MY_AUG_CONFIG} \
   # --JAVA_PATH=${JAVA_PATH} \
    --species=Pocillopora_tuahiniensis \
    --gff3

echo "BRAKER3 pipeline completed at:" $(date)
```

Submitted batch job 63517712


## trnascan 

`nano trnascan.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=uri-cpu
#SBATCH --no-requeue
#SBATCH --mem=100GB                
#SBATCH -t 48:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Starting tRNAscan-SE Analysis at:" $(date)

module load conda/latest # need to load before making any conda envs
conda activate /work/pi_hputnam_uri_edu/conda/envs/trnascan

# Define your paths
GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Pocillopora_tuahiniensis_genome_v1.0.fasta.masked"
OUT_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/trnascan_output"

mkdir -p ${OUT_DIR}

tRNAscan-SE -E \
            --threads ${SLURM_CPUS_PER_TASK} \
            -o ${OUT_DIR}/Ptua-tRNA.out \
            -f ${OUT_DIR}/Ptua-tRNA_struct.out \
            -m ${OUT_DIR}/Ptua-tRNA_stats.out \
            -j ${OUT_DIR}/Ptua-tRNA.gff3 \
            -a ${OUT_DIR}/Ptua-tRNA.fasta \
            -d \
            ${GENOME}

conda deactivate

echo "tRNAscan analysis complete" $(date)
```

Submitted batch job 63477672

```
grep -c ">" Ptua-tRNA.fasta
3897

# Count functional tRNAs (excludes lines containing "Possible pseudogene")
grep "^>" Ptua-tRNA.fasta | grep -v -i "pseudogene" | wc -l
2179

# Count pseudogenes only
grep "^>" Ptua-tRNA.fasta | grep -i "pseudogene" | wc -l
1718

# Extract ONLY functional tRNAs into a clean FASTA file for annotation
awk '{if(NR==1) {print $0} else {if($0 ~ /^>/) {if(flag==1) {print seq; seq=""}; if($0 ~ /pseudogene/i) {flag=0} else {flag=1; print $0}} else {if(flag==1) {seq = seq $0}}}} END {if(flag==1) print seq}' Ptua-tRNA.fasta > Ptua-tRNA-functional.fasta
```

## barrnap 

`nano barrnap.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=uri-cpu
#SBATCH --no-requeue
#SBATCH --mem=100GB                
#SBATCH -t 48:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Starting barrnap Analysis at:" $(date)

module load conda/latest # need to load before making any conda envs
conda activate /work/pi_hputnam_uri_edu/conda/envs/barrnap

GENOME="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/ptua_softmasked/Pocillopora_tuahiniensis_genome_v1.0.fasta.masked"
OUT_DIR="/scratch4/workspace/jillashey_uri_edu-Ptua_genome/barrnap_output"

mkdir -p ${OUT_DIR}

barrnap --kingdom euk \
        --threads ${SLURM_CPUS_PER_TASK} \
        --outseq ${OUT_DIR}/Ptua_rRNA.fa \
        ${GENOME} > ${OUT_DIR}/Ptua_rRNA.gff3

echo "barrnap complete" $(date)
conda deactivate
```

Submitted batch job 63477732.

```
grep -c ">" Ptua_rRNA.fa 
130
```

## UTR annotation

https://github.com/Gaius-Augustus/BRAKER/blob/utr_from_stringtie/scripts/stringtie2utr.py 

`nano UTR_annotation.sh`

```
#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24         
#SBATCH --partition=uri-cpu
#SBATCH --no-requeue
#SBATCH --mem=100GB                
#SBATCH -t 48:00:00                
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o slurm-%j.out
#SBATCH -e slurm-%j.error
#SBATCH -D /scratch4/workspace/jillashey_uri_edu-Ptua_genome

echo "Starting tRNAscan-SE Analysis at:" $(date)

module load python/3.9.19

# python script from https://github.com/Gaius-Augustus/BRAKER/blob/utr_from_stringtie/scripts/stringtie2utr.py 

echo "UTR annotation starting" $(date)

##REVISE WITH MY DATA INPUT
python stringtie2utr.py -g braker.gtf -s GeneMark-ETP/rnaseq/stringtie/transcripts_merged.gff -o braker_with_utrs.gtf

echo "UTR annotation complete" $(date)
```

## egg nog

```
module load uri/main all/eggnog-mapper/2.1.9-foss-2022a
```

## IPS

```
module load uri/main all/InterProScan/5.73-104.0-foss-2024a
```

## merge annotations 

https://funannotate.readthedocs.io/en/latest/annotate.html
