# My_Bio_Project_1
# Variant Calling Pipeline

A fast and high-confidence bioinformatics pipeline designed to detect Single Nucleotide Polymorphisms (SNPs) and Insertions/Deletions (Indels) from raw next-generation sequencing (NGS) data. This workflow processes paired-end data for sample **SRR7279520**, utilizing `fastp` for automated trimming and `bcftools` for both variant calling and stringent post-call quality filtering.

## Features
- **Quality Control:** Raw read evaluation using `FastQC`.
- **Trimming and Adapter Removal:** Automated ultra-fast low-quality base trimming and adapter clipping using `fastp`.
- **Alignment:** Accurate mapping to the reference genome using `BWA-MEM`.
- **Sorting and Indexing:** Data stream management using `SAMtools`.
- **Variant Calling:** Efficient and sensitive germline variant identification via `bcftools mpileup` and `bcftools call`.
- **Quality Filtering:** Post-calling hard filtering via `bcftools filter` to isolate high-confidence variants.

---

## Repository Structure
```text
Thando2805/
├── README.md                 # Project documentation and summary
├── thando.sh.sh              # Main pipeline executable shell script
├── SRR7279520_1_fastqc.html  # Pre-trimming FastQC report (Forward reads)
├── SRR7279520_2_fastqc.html  # Pre-trimming FastQC report (Reverse reads)
├── fastp_report.html         # Quality control and trimming report from fastp
├── stats.txt                 # Raw/Unfiltered variant call statistics
├── snps_final_stats.txt      # Post-filter high-quality SNP metrics
└── indels_final_stats.txt    # Post-filter high-quality Indel metricsading code-1782995922427.md…]()
```
## Requirements and Dependencies
**Ensure the following tools are installed and available in your environment path:**
- **FastQC**
- **fastp**
- **BWA (v0.7.17+)**
- **SAMtools (v1.19+)**
- **bcftools (v1.19+)**

## Usage Guide
To execute the automated pipeline, run the main bash script providing your paired-end data and targeted reference genome:
```bash
thando.sh.sh -1 SRR7279520_1.fastq -2 SRR7279520_2.fastq -r reference.fa
```
## Quality Control and Filtering Results
**Below is a summary of metrics evaluating the pipeline's performance across both raw data quality check and final filtered variants:**

## 1. Data Quality Control
- **Pre-Trimming:** Raw read quality metrics are documented in SRR7279520_1_fastqc.html and SRR7279520_2_fastqc.html
- **Trimming Profile:** Global trimming stats, adapter removal sequences, and post-filtering length distributions are processed and stored in fastp_report.html.

## 2. Global Raw Variant Statistics (stats.txt)
- Total Raw Records: ~2.47 Million variants
- Raw SNPs: 2,293,753
- Raw Indels: 174,072
- Overall Ti/Tv Ratio: 1.24

## 3. High-Confidence SNPs (snps_final_stats.txt)
- Filtered SNP Count: 7,677 high-quality variants (100% SNPs)
- Ti/Tv Ratio: 1.16
- Multiallelic Sites: 30
- Singletons: 4,287 (55.8%)
- Top Transition Patterns: A>G (1,390) and T>C (1,347)
- Depth Spectrum: 21x to 324x coverage

## 4. High-Confidence Indels (indels_final_stats.txt)
- Filtered Indel Count: 263 high-quality variants (100% Indels)
- Singletons: 105 (40%)
- Size Profile: Highly enriched for 1bp changes (88 insertions, 68 deletions)
- Quality and Depth Spectrum: QUAL ≥ 50.0 | Depth 21x to 249x
