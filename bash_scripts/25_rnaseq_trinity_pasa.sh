## Original code by Sam White and can be found here: https://github.com/urol-e5/timeseries_molecular/blob/841df3e396b9ceaa1cdd26b3743b8439cffc1405/F-Ptua/code/00.30-F-Ptua-transcriptome-assembly-Trinity.md

library(knitr)
library(reticulate)
knitr::opts_chunk$set(
  echo = TRUE,         # Display code chunks
  eval = FALSE,        # Evaluate code chunks
  warning = FALSE,     # Hide warnings
  message = FALSE,     # Hide messages
  comment = ""         # Prevents appending '##' to beginning of lines in code output
)

# DIRECTORIES
top_output_dir <- file.path("..", "output")

output_dir <- file.path(top_output_dir, "00.30-F-Ptua-transcriptome-assembly-Trinity")
de_novo_output_dir <- file.path(output_dir, "de_novo_assembly")
genome_guided_output_dir <- file.path(output_dir, "genome_guided_assembly")
pasa_container_dir <- file.path("/home", "shared", "containers")
PASA_HOME <- "/usr/local/src/PASApipeline"
pasa_output_dir <- file.path(output_dir, "PASA")
stringtie_gtf_dir <- file.path(top_output_dir, "02.20-F-Ptua-RNAseq-alignment-HiSat2")
trimmed_reads_dir <- file.path(top_output_dir, "01.00-F-Ptua-RNAseq-trimming-fastp-FastQC-MultiQC")


# FILES
bam_alignment <- file.path(top_output_dir, "02.20-F-Ptua-RNAseq-alignment-HiSat2", "sorted-bams-merged.bam")

## Path for genome will be relative to PASA output dir
genome_fasta <- file.path("..", "..", "..", "data", "Pocillopora_meandrina_HIv1.assembly.fasta")
genome_gff <- file.path("..", "data", "Pocillopora_meandrina_HIv1.genes.gff3")
denovo_assembly_name <- "ptua-denovo-Trinity"
genome_guided_assembly_name <- "ptua-GG-Trinity"
pasa_bed <- "ptua-PASA.bed"
pasa_container <- "pasapipeline.v2.5.3.simg"
pasa_gff <- "ptua-PASA.gff3"
stringtie_gtf <- file.path(stringtie_gtf_dir, "Pocillopora_meandrina_HIv1.assembly.stringtie.gtf")

#SETTINGS
## THREADS
threads <- "44"

## MAX RAM
max_ram <- "100G"

# PROGRAMS
samtools <- file.path("/home", "shared", "samtools-1.12", "samtools")


# FORMATTING
line <- "-----------------------------------------------"

# Export these as environment variables for bash chunks.
Sys.setenv(
  bam_alignment = bam_alignment,
  denovo_assembly_name = denovo_assembly_name,
  de_novo_output_dir = de_novo_output_dir,
  genome_fasta = genome_fasta,
  genome_gff = genome_gff,
  genome_guided_assembly_name = genome_guided_assembly_name,
  genome_guided_output_dir = genome_guided_output_dir,
  line = line,
  max_ram = max_ram,
  output_dir = output_dir,
  top_output_dir = top_output_dir,
  pasa_bed = pasa_bed,
  pasa_container = pasa_container,
  pasa_container_dir = pasa_container_dir,
  pasa_gff = pasa_gff,
  PASA_HOME = PASA_HOME,
  pasa_output_dir = pasa_output_dir,
  samtools = samtools,
  stringtie_gtf_dir = stringtie_gtf_dir,
  stringtie_gtf = stringtie_gtf,
  threads = threads,
  trimmed_reads_dir = trimmed_reads_dir
)

# Directories
top_output_dir="../output"

output_dir="${top_output_dir}/00.30-F-Ptua-transcriptome-assembly-Trinity"
de_novo_output_dir="${output_dir}/de_novo_assembly"
genome_guided_output_dir="${output_dir}/genome_guided_assembly"
pasa_output_dir="${output_dir}/PASA"
trimmed_reads_dir="${top_output_dir}/01.00-F-Ptua-RNAseq-trimming-fastp-FastQC-MultiQC"

# FILES
bam_alignment="${top_output_dir}/02.20-F-Ptua-RNAseq-alignment-HiSat2/sorted-bams-merged.bam"
denovo_assembly_name="ptua-denovo-Trinity"
genome_guided_assembly_name="ptua-GG-Trinity"

# PASA INPUT FILES
####### NEED TO BE RELATIVE TO PASA SUBDIRECTORY #######
genome_fasta="../../../data/Pocillopora_meandrina_HIv1.assembly.fasta"
genome_gff="../../../data/Pocillopora_meandrina_HIv1.genes-validated.gff3"
pasa_container="pasapipeline.v2.5.3.simg"
PASA_HOME="/usr/local/src/PASApipeline"
stringtie_gtf="../../../output/02.20-F-Ptua-RNAseq-alignment-HiSat2/Pocillopora_meandrina_HIv1.assembly.stringtie.gtf 
"

## THREADS
threads="44"

## MAX RAM
max_ram="100G"

# Make output directoy, if it doesn't exist
mkdir --parents ${de_novo_output_dir}
mkdir --parents ${pasa_output_dir}

## Inititalize arrays
R1_array=()
R2_array=()

# Variables for R1/R2 lists
R1_list=""
R2_list=""

# Create array of fastq R1 files
R1_array=(${trimmed_reads_dir}/*R1_001.fastp-trim.fq.gz)

# Create array of fastq R2 files
R2_array=(${trimmed_reads_dir}/*R2_001.fastp-trim.fq.gz)

# Create list of fastq files used in analysis
## Uses parameter substitution to strip leading path from filename
if [ ! -f "${de_novo_output_dir}/fastq.list.txt" ]; then
  for fastq in ${trimmed_reads_dir}/*.fq.gz
  do
    echo "${fastq##*/}" >> ${de_novo_output_dir}/fastq.list.txt
  done
fi

# Create comma-separated lists of FastQ reads
R1_list=$(echo "${R1_array[@]}" | tr " " ",")
R2_list=$(echo "${R2_array[@]}" | tr " " ",")

singularity exec \
-B /home \
-e trinityrnaseq.v2.15.2.simg \
Trinity \
--seqType fq \
--max_memory ${max_ram} \
--CPU ${threads} \
--SS_lib_type RF \
--left "${R1_list}" \
--right "${R2_list}" \
--output ${de_novo_output_dir}/trinity_out_dir \
--full_cleanup \
> ${de_novo_output_dir}/trinity.log \
2>&1

# Rename generic assembly FastA
mv ${de_novo_output_dir}/trinity_out_dir.Trinity.fasta \
${de_novo_output_dir}/${denovo_assembly_name}.fasta

mv ${de_novo_output_dir}/trinity_out_dir.Trinity.fasta.gene_trans_map \
${de_novo_output_dir}/${denovo_assembly_name}.gene_trans_map

mv ${de_novo_output_dir}/trinity.log \
${de_novo_output_dir}/${denovo_assembly_name}.log

singularity exec -B /home \
-e trinityrnaseq.v2.15.2.simg \
/usr/local/bin/util/TrinityStats.pl \
../output/00.30-F-Ptua-transcriptome-assembly-Trinity/de_novo_assembly/ptua-denovo-Trinity.fasta \
> ../output/00.30-F-Ptua-transcriptome-assembly-Trinity/de_novo_assembly/ptua-denovo-Trinity.stats

${samtools} faidx \
${de_novo_output_dir}/${denovo_assembly_name}.fasta

cd ${de_novo_output_dir}

md5sum ${denovo_assembly_name}.fasta | tee ${denovo_assembly_name}.fasta.md5

singularity exec \
-B /home -e trinityrnaseq.v2.15.2.simg \
Trinity \
--genome_guided_bam ${bam_alignment} \
--genome_guided_max_intron 10000 \
--max_memory ${max_ram} \
--CPU ${threads} \
--SS_lib_type RF \
--output ${genome_guided_output_dir}/trinity_out_dir \
--full_cleanup \
> ${genome_guided_output_dir}/trinity.log 2>&1

# Rename generic assembly FastA
mv ${genome_guided_output_dir}/trinity_out_dir.Trinity-GG.fasta \
${genome_guided_output_dir}/${genome_guided_assembly_name}.fasta

mv ${genome_guided_output_dir}/trinity_out_dir.Trinity-GG.fasta.gene_trans_map \
${genome_guided_output_dir}/${genome_guided_assembly_name}.gene_trans_map

mv ${genome_guided_output_dir}/trinity.log \
${genome_guided_output_dir}/${genome_guided_assembly_name}.log

${samtools} faidx \
${genome_guided_output_dir}/${genome_guided_assembly_name}.fasta

cd ${de_novo_output_dir}

md5sum ${denovo_assembly_name}.fasta | tee ${denovo_assembly_name}.fasta.md5

singularity exec -B /home \
-e trinityrnaseq.v2.15.2.simg \
/usr/local/bin/util/TrinityStats.pl \
../output/00.30-F-Ptua-transcriptome-assembly-Trinity/genome_guided_assembly/ptua-GG-Trinity.fasta \
> ../output/00.30-F-Ptua-transcriptome-assembly-Trinity/genome_guided_assembly/ptua-GG-Trinity.stats

cat ${de_novo_output_dir}/${denovo_assembly_name}.fasta \
${genome_guided_output_dir}/${genome_guided_assembly_name}.fasta \
> ${pasa_output_dir}/transcripts.fasta

# Count transcripts in each file
denovo_count=$(grep -c "^>" ${de_novo_output_dir}/${denovo_assembly_name}.fasta)
genome_guided_count=$(grep -c "^>" ${genome_guided_output_dir}/${genome_guided_assembly_name}.fasta)
pasa_count=$(grep -c "^>" ${pasa_output_dir}/transcripts.fasta)

# Calculate sum of first two counts
sum=$((denovo_count + genome_guided_count))

# Compare sum to PASA count
echo "De novo count: $denovo_count"
echo "Genome-guided count: $genome_guided_count"
echo "Sum: $sum"
echo "PASA count: $pasa_count"

if [ $sum -eq $pasa_count ]; then
    echo "✓ Counts match: $sum = $pasa_count"
else
    echo "✗ Counts do not match: $sum ≠ $pasa_count (difference: $((pasa_count - sum)))"
fi

singularity exec \
-B /home \
-e ${pasa_container_dir}/${pasa_container} \
$PASA_HOME/misc_utilities/accession_extractor.pl \
< ${de_novo_output_dir}/${denovo_assembly_name}.fasta \
> ${pasa_output_dir}/tdn.accs

head ${pasa_output_dir}/tdn.accs

cd ${pasa_output_dir}

singularity exec \
-B /home \
-e \
--env USER="$USER" \
${pasa_container} \
$PASA_HOME/bin/seqclean \
transcripts.fasta \
-c 16

cd ${pasa_output_dir}

#### Fix schema key length issue ####
singularity exec ${pasa_container} \
cat /usr/local/src/PASApipeline/schema/cdna_alignment_mysqlschema \
> cdna_alignment_mysqlschema

# Fix all variations of gene_id and model_id indexes
sed -i 's/KEY gene_id_idx (gene_id)/KEY gene_id_idx (gene_id(255))/g' cdna_alignment_mysqlschema
sed -i 's/KEY mod_idx (model_id)/KEY mod_idx (model_id(255))/g' cdna_alignment_mysqlschema
sed -i 's/(gene_id)/(gene_id(255))/g' cdna_alignment_mysqlschema
sed -i 's/(model_id)/(model_id(255))/g' cdna_alignment_mysqlschema
sed -i 's/KEY gene_idx (annotation_version,gene_id)/KEY gene_idx (annotation_version,gene_id(255))/g' cdna_alignment_mysqlschema

singularity exec \
-B /home \
-B /var/run/mysqld/mysqld.sock:/var/run/mysqld/mysqld.sock \
-B $PWD/conf.txt:$PASA_HOME/pasa_conf/conf.txt \
-B $PWD/cdna_alignment_mysqlschema:$PASA_HOME/schema/cdna_alignment_mysqlschema \
${pasa_container} \
$PASA_HOME/Launch_PASA_pipeline.pl \
--config alignAssembly.config \
--create \
--run \
--genome ${genome_fasta} \
--transcripts transcripts.fasta.clean \
--trans_gtf ${stringtie_gtf} \
--ALT_SPLICE \
-T \
-u transcripts.fasta \
--ALIGNERS blat,gmap,minimap2 \
--TDN tdn.accs \
--transcribed_is_aligned_orient \
--annot_compare \
-L \
--annots ${genome_gff} \
--TRANSDECODER \
--CPU ${threads}

singularity exec \
-B /home \
-B /var/run/mysqld/mysqld.sock:/var/run/mysqld/mysqld.sock \
-B $PWD/conf.txt:$PASA_HOME/pasa_conf/conf.txt \
-B $PWD/cdna_alignment_mysqlschema:$PASA_HOME/schema/cdna_alignment_mysqlschema \
${pasa_container} \
$PASA_HOME/Launch_PASA_pipeline.pl \
-c alignAssembly.config \
--ALT_SPLICE \
-g ${genome_fasta} \
-t all.transcripts.fasta.clean \
--CPU ${threads}

singularity exec \
-B /home \
-B /var/run/mysqld/mysqld.sock:/var/run/mysqld/mysqld.sock \
-B $PWD/conf.txt:$PASA_HOME/pasa_conf/conf.txt \
-B $PWD/cdna_alignment_mysqlschema:$PASA_HOME/schema/cdna_alignment_mysqlschema \
${pasa_container} \
$PASA_HOME/Launch_PASA_pipeline.pl \
-c annotCompare.config \
--annot_compare \
-L \
--annots ptua_pasa.gene_structures_post_PASA_updates.2550175.gff3 \
-g ${genome_fasta} \
-t all.transcripts.fasta.clean \
--CPU ${threads}

cd "${pasa_output_dir}"

md5sum ptua_pasa.gene_structures_post_PASA_updates.3761026.gff3 | tee ptua_pasa.gene_structures_post_PASA_updates.3761026.gff3.md5

md5sum ptua_pasa.gene_structures_post_PASA_updates.3761026.bed | tee ptua_pasa.gene_structures_post_PASA_updates.3761026.bed.md5

cd "${pasa_output_dir}"
cp ptua_pasa.gene_structures_post_PASA_updates.3761026.gff3 "${pasa_gff}"

cp ptua_pasa.gene_structures_post_PASA_updates.3761026.bed "${pasa_bed}"

md5sum "${pasa_gff}" | tee "${pasa_gff}".md5
md5sum "${pasa_bed}" | tee "${pasa_bed}".md5

printf '%s\n\n' "Original GFF feature counts:"
awk '!/^#/ && !/^[[:space:]]*$/ && NF > 0 && $3 != "" {print $3}' ${genome_gff} \
| sort | uniq -c | sort -rn | awk '{print $2, $1}'

echo ""
echo "${line}"
echo ""

printf "%s\n\n" "Updated GFF feature counts:"
awk -F "\t" '!/^#/ && !/^[[:space:]]*$/ && NF > 0 && $3 != "" {print $3}' "${pasa_output_dir}"/"${pasa_gff}" \
| sort | uniq -c | sort -rn | awk '{print $2, $1}'

cd "${pasa_output_dir}"

awk '/^#PROT / {print ">" $2 "." $3 "\n" $4}' "${pasa_gff}" > ptua-proteins-PASA.fasta

printf "%s\n\n" "Original protein counts:"
grep --count "^#PROT" "${pasa_gff}"

echo ""
echo "${line}"
echo ""

printf "%s\n\n" "Extracted protein counts:"
grep --count "^>" ptua-proteins-PASA.fasta

# Create FastA Index
${samtools} faidx ptua-proteins-PASA.fasta

cd "${pasa_output_dir}"
md5sum ptua-proteins-PASA.fasta | tee ptua-proteins-PASA.fasta.md5