2025-10-23 18:20:50 20377834269 m84100_251021_203206_s3.hifi_reads.bam
2025-10-23 18:20:50  129896502 m84100_251021_203206_s3.hifi_reads.bam.pbi


1. Jellyfish
2. genoscope
3. MitoHiFi assembly
4. Blast filtering
5. Hifiasm
6. Quast
7. RepeatModeler
8. RepeatMasker
9. BUSCO
10. funannotate
11. Interproscan
12. EggNOG


## What to read in the SMRT Link report (and target ranges)

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


# Start Assembly

## Convert BAM to FASTQ

bam2fastq

1. Jellyfish
2. genoscope
3. MitoHiFi assembly
4. Blast filtering
5. Hifiasm
6. Quast
7. RepeatModeler
8. RepeatMasker
9. BUSCO
10. funannotate
11. Interproscan
12. EggNOG