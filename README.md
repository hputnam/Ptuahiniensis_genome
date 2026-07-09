## Assembly and annotation of the genome for Pocillopora tuahiniensis 

### Workflow 

The following workflow will be presented along with the corresponding bash script in this repo. 

### [`01_checksums.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/01_checksums.sh)

Runs a checksum on the raw data to ensure it downloaded to the remote server properly. 

### [`02_check_bam.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/02_check_bam.sh)

Checkes that file is intact and headers are present.

### [`03_convert_bam2fastq.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/03_convert_bam2fastq.sh)

Convert the raw BAM file to a fastq file. 

### [`04_convert_fastq_fasta.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/04_convert_fastq_fasta.sh)

Using [seqtk](https://github.com/lh3/seqtk), convert the fastq to a fasta file and summarize raw read lengths.

### [`05_kmercount_jellyfish.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/05_kmercount_jellyfish.sh)

Count the k-mers of the raw fastq file using [Jellyfish](https://github.com/gmarcais/jellyfish).

### [`06_mito_assemble.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/06_mito_assemble.sh)

Assemble the mitochondrial genome using [MitoHiFi](https://github.com/marcelauliano/MitoHiFi). For the Ptua genome, we used the P. damicornis [mitochondrial genome](https://www.ncbi.nlm.nih.gov/nuccore/EF526302) as a reference. 

### [`07_blastn_contam_euk.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/07_blastn_contam_euk.sh)

[BLAST](https://blast.ncbi.nlm.nih.gov/Blast.cgi) the eukaryotic contaminant sequences fasta against the raw genoem reads to search for potential contamination. 

### [`08_blastn_contam_viral.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/08_blastn_contam_viral.sh)

[BLAST](https://blast.ncbi.nlm.nih.gov/Blast.cgi) the representative viral genome sequences fasta against the raw genoem reads to search for potential contamination. 

### [`09_blastn_contam_prok.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/09_blastn_contam_prok.sh)

[BLAST](https://blast.ncbi.nlm.nih.gov/Blast.cgi) the representative prokaryotic genome sequences fasta against the raw genoem reads to search for potential contamination. 

### [`10_blastn_contam_mito.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/10_blastn_contam_mito.sh)

[BLAST](https://blast.ncbi.nlm.nih.gov/Blast.cgi) the mitochondrial sequences identified by MitoHiFi against the raw genoem reads so they can be removed from assembly. 

### [`11_blastn_contam_sym.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/11_blastn_contam_sym.sh)

[BLAST](https://blast.ncbi.nlm.nih.gov/Blast.cgi) the C1 and D1 symbiont genome sequences fasta against the raw genoem reads to search for potential symbiont contamination. 

### [`12_blast_filter.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/12_blast_filter.sh)

From all blast results, filter any hits that have a bit score >1000. These are contaminants to remove.

### [`13_filter_contaminants.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/13_filter_contaminants.sh)

Remove contaminants from the raw genome reads. 

### [`14_hifiasm_s55.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/14_hifiasm_s55.sh)

Assemble genome using [hifiasm](https://github.com/chhylp123/hifiasm). 

### [`15_ntlinks.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/15_ntlinks.sh)

Further scaffold the assembled genome using [ntlinks](https://github.com/BirolLab/ntLink). 

### [`16_repeatmodeler.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/16_repeatmodeler.sh)

Create a repetitive library from the assembled genome with [RepeatModeler](https://github.com/Dfam-consortium/RepeatModeler). 

### [`17_repeatmasker.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/17_repeatmasker.sh)

Soft-mask the repeats in the genome using [RepeatMasker](https://github.com/Dfam-consortium/RepeatMasker).

### [`18_quast_assembled.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/18_quast_assembled.sh)

Evaluate the genome assembly quality with [Quast](https://github.com/ablab/quast). 

### [`19_busco_assembled.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/19_busco_assembled.sh)

Assess the completeness of the genome with [BUSCO](https://busco.ezlab.org/) and the metazoan database (`metazoa_odb10`).

### [`20_rename_genome.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/20_rename_genome.sh)

Rename genome and scaffolds so that the genome is now named `Pocillopora_tuahiniensis_genome_v1.0.fasta` and the scaffolds are named `Pocillopora_tuahiniensis_scaffold1`, 2, 3, etc. This [file](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/output/assembly/final/scaffold_name_map.txt) has the original scaffold names along with the renamed scaffolds. 

### [`21_pull_braker.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/21_pull_braker.sh)

Install [BRAKER3](https://github.com/Gaius-Augustus/BRAKER) (there are a lot of dependencies). Braker documentation recommends using the provided braker [docker container](https://hub.docker.com/r/teambraker/braker3) for installation. BRAKER3 will be used to structurally annotate the genome. 

### [`22_proteins_for_braker3.sh`](https://github.com/hputnam/Ptuahiniensis_genome/blob/main/bash_scripts/22_proteins_for_braker3.sh)

Obtain protein sequences for braker training. Braker uses protein sequences from closely and distantly related species. For this genome, I used sequences from: 

- [Pocillopora damicornis](http://pdam.reefgenomics.org/download/pdam_proteins.fasta.gz)
- [Pocillopora verrucosa](http://pver.reefgenomics.org/download/Pver_proteins_names_v1.0.faa.gz)
- [Pocillopora acuta](http://cyanophora.rutgers.edu/Pocillopora_acuta/Pocillopora_acuta_HIv2.genes.pep.faa.gz)
- [Pocillopora meandrina](http://cyanophora.rutgers.edu/Pocillopora_acuta/Pocillopora_meandrina_HIv1.genes.pep.faa.gz)
- Protein sequences generated by Trinity and PASA from the Pocillopora tuahinensis transcriptome (see below)
- [Metazoan proteins from OrthoDB](https://bioinf.uni-greifswald.de/bioinf/partitioned_odb12/Metazoa.fa.gz), as recommended by braker documentation 

