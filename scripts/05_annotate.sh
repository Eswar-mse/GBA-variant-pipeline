#!/usr/bin/env bash
# Step 5 — Annotation with Ensembl VEP (SIFT + PolyPhen)
#
# Usage: ./05_annotate.sh <input_PASS.vcf.gz> <output_prefix>
#   e.g. ./05_annotate.sh results/variants/gba_cohort_2sample.PASS.vcf.gz \
#                         results/variants/gba_cohort_2sample.annotated
#
# Requires: conda env `vep-env`, with the GRCh37 VEP cache (release 105)
# manually downloaded and extracted to ~/.vep — see data/provenance.md.
# (The `vep_install` auto-downloader also pulls a full-genome FASTA by
# default and is very slow; manual cache-only download is much faster —
# see data/provenance.md for the exact URL used.)
#
# Run from the project root (~/Documents/Projects/NGS-starter)

set -euo pipefail

INPUT=$1
OUT_PREFIX=$2

echo ">>> Running VEP (GRCh37, offline, SIFT + PolyPhen)"
conda run -n vep-env vep \
  --input_file ${INPUT} \
  --output_file ${OUT_PREFIX}.vcf \
  --cache --dir_cache ~/.vep \
  --offline --assembly GRCh37 \
  --sift b --polyphen b \
  --vcf --force_overwrite

echo ">>> Done. Annotated VCF: ${OUT_PREFIX}.vcf"
echo ">>> VEP also auto-generates ${OUT_PREFIX}.vcf_summary.html"
echo "    (consequence-type pie chart, variant class breakdown — used directly in the README)"
