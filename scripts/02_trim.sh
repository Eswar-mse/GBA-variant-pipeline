#!/usr/bin/env bash
# Step 2 — Adapter trimming with fastp, then re-run QC and combine with MultiQC
#
# Usage: ./02_trim.sh <SAMPLE> <LIBRARY_ID>
#   e.g. ./02_trim.sh NIST7035 TAAGGCGA
#        ./02_trim.sh NIST7086 CGTACTAG
#
# Requires: conda env `ngs-gba` (fastp), `fastqc-env` (post-trim QC)
# Run from the project root (~/Documents/Projects/NGS-starter)

set -euo pipefail

SAMPLE=$1
LIBID=$2

for LANE in L001 L002; do
  echo ">>> Trimming ${SAMPLE} ${LANE}"
  conda run -n ngs-gba fastp \
    -i data/raw/${SAMPLE}_${LIBID}_${LANE}_R1_001.fastq.gz \
    -I data/raw/${SAMPLE}_${LIBID}_${LANE}_R2_001.fastq.gz \
    -o results/trimmed/${SAMPLE}_${LANE}_R1_trimmed.fastq.gz \
    -O results/trimmed/${SAMPLE}_${LANE}_R2_trimmed.fastq.gz \
    --detect_adapter_for_pe \
    --json results/trimmed/${SAMPLE}_${LANE}_fastp.json \
    --html results/trimmed/${SAMPLE}_${LANE}_fastp.html
done

echo ">>> Post-trim FastQC"
conda run -n fastqc-env fastqc results/trimmed/${SAMPLE}*.fastq.gz -o results/fastqc/

echo ">>> Combining all QC reports with MultiQC"
conda run -n ngs-gba multiqc results/fastqc/ results/trimmed/ \
  -o results/multiqc/ -n full_project_multiqc --force

echo ">>> Done. See results/multiqc/full_project_multiqc.html"
