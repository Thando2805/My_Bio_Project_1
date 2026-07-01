#!/bin/bash

# PREREQUISITES and TOOLS REQUIRED
# ==========================================
# Make sure these are installed on your system before running:
# - fastqc (Quality Control)
# - fastp (Read trimming & QC)
# - multiqc (Aggregate QC reports)
# - bwa (Read Alignment)
# - samtools (BAM processing & Indexing)
# - bcftools (Variant calling & Filtering)
# - conda (With 'igv_java21' environment for visualization

# ==========================================
# STEP 1: DATA DOWNLOAD and DIRECTORY SETUP
# ==========================================
echo "Setting up project directory and downloading data..."
mkdir -p ~/myproject
cd ~/myproject

# Download FASTQ files from ENA
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR727/004/SRR7279494/SRR7279494_2.fastq.gz
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR727/000/SRR7279520/SRR7279520_1.fastq.gz
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR727/000/SRR7279520/SRR7279520_2.fastq.gz

# Unzip target files
if [ -f "SRR7279520_1.fastq.gz" ]; then gunzip SRR7279520_1.fastq.gz; fi
if [ -f "SRR7279520_2.fastq.gz" ]; then gunzip SRR7279520_2.fastq.gz; fi

# ==========================================
# STEP 2: READ TRIMMING (fastp)
# ==========================================
echo "Trimming reads with fastp..."
mkdir -p trimmed_fastp

# Run fastp for SRR7279494
fastp -i SRR7279494_1.fastq.gz -I SRR7279494_2.fastq.gz \
      -o trimmed_fastp/SRR7279494_1_trimmed.fastq.gz \
      -O trimmed_fastp/SRR7279494_2_trimmed.fastq.gz \
      -h trimmed_fastp/fastq_report_494.html \
      -j trimmed_fastp/fastq_report_494.json \
      --thread 4

# Run fastp for SRR7279520
fastp -i SRR7279520_1.fastq -I SRR7279520_2.fastq \
      -o trimmed_fastp/SRR7279520_1_trimmed.fastq \
      -O trimmed_fastp/SRR7279520_2_trimmed.fastq \
      -h trimmed_fastp/fastq_report_520.html \
      -j trimmed_fastp/fastq_report_520.json \
      --thread 4 

# ==========================================
# STEP 3: REFERENCE GENOME PREPARATION
# ==========================================
echo "Indexing reference genome..."
mkdir -p reference_genome
cd reference_genome

bwa index GCA_036512215.2_SLM_r2.1_genomic.fna
samtools faidx GCA_036512215.2_SLM_r2.1_genomic.fna
ls -lah GCA_036512215.2_SLM_r2.1_genomic.fna*

# ==========================================
# STEP 4: READ ALIGNMENT (BWA MEM)
# ==========================================
echo "Aligning reads and generating sorted BAM..."
# Aligning utilizing the pipeline directly to sorted BAM variant to save disk space
bwa mem -t 4 GCA_036512215.2_SLM_r2.1_genomic.fna \
        ../SRR7279520_1.fastq ../SRR7279520_2.fastq 2> bwa.log | \
        samtools view -bS | \
        samtools sort -o aligned_sorted.bam

# Index the BAM file
samtools index aligned_sorted.bam

# ==========================================
# STEP 5: VARIANT CALLING (BCFtools)
# ==========================================
echo "🔍 Calling variants with BCFtools..."
bcftools mpileup -f GCA_036512215.2_SLM_r2.1_genomic.fna aligned_sorted.bam -t 4 | \
                 bcftools call -mv -o variants.vcf

# Generate raw statistics
bcftools stats variants.vcf > stats.txt

# Extract raw subsets
bcftools view -v snps variants.vcf -o snps_raw.vcf
bcftools view -v indels variants.vcf -o indels_raw.vcf

# ==========================================
# STEP 6: VARIANT FILTERING
# ==========================================
echo "Filtering variants..."

# Hard initial filtering (QUAL > 30, DP > 10)
bcftools view -v snps variants.vcf | bcftools filter -i 'QUAL>30 && INFO/DP>10' -o snps_filtered.vcf
bcftools view -v indels variants.vcf | bcftools filter -i 'QUAL>30 && INFO/DP>10' -o indels_filtered.vcf

# Final High-quality filtering
bcftools view -v snps variants.vcf | bcftools filter -i 'QUAL>50 && INFO/DP>20 && INFO/MQ>50' -o snps_final_highqual.vcf
bcftools view -v indels variants.vcf | bcftools filter -i 'QUAL>50 && INFO/DP>20' -o indels_final_highqual.vcf
bcftools filter -i 'QUAL>50 && INFO/DP>20 && INFO/MQ>50' variants.vcf -o variants_final_highqual.vcf

# Generate final statistics
bcftools stats snps_final_highqual.vcf > snps_final_stats.txt
bcftools stats indels_final_highqual.vcf > indels_final_stats.txt
bcftools stats variants_final_highqual.vcf > variants_final_stats.txt

# installing igv
conda create -n igv_java21 openjdk=21 igv
conda activate igv_java21

# Launch IGV
igv

# End of pipeline