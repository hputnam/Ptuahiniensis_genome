## Original code by Sam White and can be found here: https://github.com/urol-e5/timeseries_molecular/blob/841df3e396b9ceaa1cdd26b3743b8439cffc1405/F-Ptua/code/01.00-F-Ptua-RNAseq-trimming-fastp-FastQC-MultiQC.md

{
echo "#### Assign Variables ####"
echo ""

echo "# Data directories"
echo 'export timeseries_dir=/home/shared/8TB_HDD_01/sam/gitrepos/urol-e5/timeseries_molecular'
echo 'export output_dir_top=${timeseries_dir}/F-Ptua/output/01.00-F-Ptua-RNAseq-trimming-fastp-FastQC-MultiQC'
echo 'export raw_reads_dir=${timeseries_dir}/F-Ptua/data/rnaseq-raw-fastqs'
echo ""

echo "# Paths to programs"
echo 'export programs_dir="/home/shared"'
echo 'export fastp="${programs_dir}/fastp"'
echo 'export fastqc=${programs_dir}/FastQC-0.12.1/fastqc'
echo 'export multiqc=/home/sam/programs/mambaforge/bin/multiqc'
echo ""

echo "# Set FastQ filename patterns"
echo "export fastq_pattern='*.fastq.gz'"
echo "export R1_fastq_pattern='*_R1_*.fastq.gz'"
echo "export R2_fastq_pattern='*_R2_*.fastq.gz'"
echo "export trimmed_fastq_pattern='*fastp-trim.fq.gz'"
echo ""

echo "# Set number of CPUs to use"
echo 'export threads=40'
echo ""


echo "## Inititalize arrays"
echo 'export fastq_array_R1=()'
echo 'export fastq_array_R2=()'
echo 'export raw_fastqs_array=()'
echo 'export R1_names_array=()'
echo 'export R2_names_array=()'
echo ""

echo "# Programs associative array"
echo "declare -A programs_array"
echo "programs_array=("
echo '[fastp]="${fastp}" \'
echo '[fastqc]="${fastqc}" \'
echo '[multiqc]="${multiqc}" \'
echo ")"
echo ""

echo "# Print formatting"
echo 'export line="--------------------------------------------------------"'
echo ""
} > .bashvars

cat .bashvars

# Load bash variables into memory
source .bashvars

# Make output directories, if it doesn't exist
mkdir --parents "${output_dir_top}"

# Change to raw reads directory
cd "${raw_reads_dir}"

# Create arrays of fastq R1 files and sample names
for fastq in ${R1_fastq_pattern}
do
  fastq_array_R1+=("${fastq}")
  R1_names_array+=("$(echo "${fastq}" | awk -F"_" '{print $1}')")
done

# Create array of fastq R2 files
for fastq in ${R2_fastq_pattern}
do
  fastq_array_R2+=("${fastq}")
  R2_names_array+=("$(echo "${fastq}" | awk -F"_" '{print $1}')")
done

# Create list of fastq files used in analysis
# Create MD5 checksum for reference
if [ ! -f "${output_dir_top}"/raw-fastq-checksums.md5 ]; then
for fastq in *.gz
  do
    md5sum ${fastq} >> "${output_dir_top}"/raw-fastq-checksums.md5
  done
fi

# Run fastp on files
# Adds JSON report output for downstream usage by MultiQC
for index in "${!fastq_array_R1[@]}"
do
  R1_sample_name=$(echo "${R1_names_array[index]}")
  R2_sample_name=$(echo "${R2_names_array[index]}")
  ${fastp} \
  --in1 ${fastq_array_R1[index]} \
  --in2 ${fastq_array_R2[index]} \
  --detect_adapter_for_pe \
  --trim_poly_g \
  --trim_poly_x \
  --trim_front1 15 \
  --trim_front2 15 \
  --thread ${threads} \
  --html "${output_dir_top}"/"${R1_sample_name}".fastp-trim.report.html \
  --json "${output_dir_top}"/"${R1_sample_name}".fastp-trim.report.json \
  --out1 "${output_dir_top}"/"${R1_sample_name}"_R1_001.fastp-trim.fq.gz \
  --out2 "${output_dir_top}"/"${R2_sample_name}"_R2_001.fastp-trim.fq.gz \
  2>> "${output_dir_top}"/fastp.stderr

  # Generate md5 checksums for newly trimmed files
  cd "${output_dir_top}"
  md5sum "${R1_sample_name}"_R1_001.fastp-trim.fq.gz > "${R1_sample_name}"_R1_001.fastp-trim.fq.gz.md5
  md5sum "${R2_sample_name}"_R2_001.fastp-trim.fq.gz > "${R2_sample_name}"_R2_001.fastp-trim.fq.gz.md5
  cd -
done

# Load bash variables into memory
source .bashvars

cd "${output_dir_top}"

############ RUN FASTQC ############


# Create array of trimmed FastQs
trimmed_fastqs_array=(${trimmed_fastq_pattern})

# Pass array contents to new variable as space-delimited list
trimmed_fastqc_list=$(echo "${trimmed_fastqs_array[*]}")

echo "Beginning FastQC on trimmed reads..."
echo ""

# Run FastQC
### NOTE: Do NOT quote raw_fastqc_list
${fastqc} \
--threads ${threads} \
--outdir "${output_dir_top}" \
--quiet \
${trimmed_fastqc_list}

echo "FastQC on trimmed reads complete!"
echo ""

############ END FASTQC ############

# Load bash variables into memory
source .bashvars


cd "${output_dir_top}"

${programs_array[multiqc]} . \
--cl-config "sp: { fastp: { fn: '*report.json' } }" \
--interactive

# Remove zip files
rm *_fastqc.zip