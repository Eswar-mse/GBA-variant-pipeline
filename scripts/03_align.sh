#!/usr/bin/env bash
# Step 3 — Alignment: BWA-MEM against full chr1 (GRCh37), merge lanes, mark duplicates
#
# NOTE: we align against the FULL chr1 reference, not a GBA1-only slice.
# GBA1 has a highly homologous nearby pseudogene (GBAP1); giving BWA the
# pseudogene sequence lets it correctly disambiguate reads instead of
# forcing falsely confident mappings. See README Step 4 for why this matters.
#
# Usage: ./03_align.sh <SAMPLE>
#   e.g. ./03_align.sh NIST7035
#
# Requires: conda env `ngs-gba` (bwa, samtools, gatk4)
# Run from the project root (~/Documents/Projects/NGS-starter)

set -euo pipefail

SAMPLE=$1
REF=data/reference/reference_chr1.fa

for LANE in L001 L002; do
  echo ">>> Aligning ${SAMPLE} ${LANE}"
  conda run -n ngs-gba bash -c "
    bwa mem -t 4 -R '@RG\tID:${SAMPLE}_${LANE}\tSM:${SAMPLE}\tPL:ILLUMINA' \
      ${REF} \
      results/trimmed/${SAMPLE}_${LANE}_R1_trimmed.fastq.gz \
      results/trimmed/${SAMPLE}_${LANE}_R2_trimmed.fastq.gz \
      | samtools sort -o results/aligned/${SAMPLE}_${LANE}.sorted.bam
  "
  conda run -n ngs-gba samtools quickcheck results/aligned/${SAMPLE}_${LANE}.sorted.bam
done

echo ">>> Merging lanes for ${SAMPLE}"
conda run -n ngs-gba samtools merge -f results/aligned/${SAMPLE}.merged.bam \
  results/aligned/${SAMPLE}_L001.sorted.bam \
  results/aligned/${SAMPLE}_L002.sorted.bam

conda run -n ngs-gba samtools index results/aligned/${SAMPLE}.merged.bam

echo ">>> Marking duplicates for ${SAMPLE}"
conda run -n ngs-gba gatk MarkDuplicates \
  -I results/aligned/${SAMPLE}.merged.bam \
  -O results/aligned/${SAMPLE}.dedup.bam \
  -M results/aligned/${SAMPLE}.dup_metrics.txt

conda run -n ngs-gba samtools index results/aligned/${SAMPLE}.dedup.bam
conda run -n ngs-gba samtools flagstat results/aligned/${SAMPLE}.dedup.bam

echo ">>> Done. Final BAM: results/aligned/${SAMPLE}.dedup.bam"
echo ">>> Recommended: open in IGV at the GBA1 region (1:155204243-155214418)"
echo "    and check ~155,212,000-155,212,150 for GBAP1 pseudogene mis-mapping artifacts."
