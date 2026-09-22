#!/usr/bin/env bash
# Step 1 — Quality control on raw FASTQ files
#
# Usage: ./01_qc.sh
# Requires: conda env `fastqc-env` (has openjdk=17 + fastqc, needed to work
# around a missing libfontmanager in the main ngs-gba env's JDK build)
#
# Run from the project root (~/Documents/Projects/NGS-starter)

set -euo pipefail

echo ">>> Running FastQC on all raw FASTQ files"
conda run -n fastqc-env fastqc data/raw/*.fastq.gz -o results/fastqc/

echo ">>> Done. Combine with MultiQC after trimming (see 02_trim.sh) for a full before/after report."
