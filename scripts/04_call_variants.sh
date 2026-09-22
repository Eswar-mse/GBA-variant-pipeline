#!/usr/bin/env bash
# Step 4 — Variant calling: HaplotypeCaller (GVCF) per sample, then joint
# genotyping and hard-filtering across all samples together.
#
# Usage: ./04_call_variants.sh <SAMPLE1> [<SAMPLE2> ...]
#   e.g. ./04_call_variants.sh NIST7035 NIST7086
#
# The GBA1 region and hard-filter thresholds below (DP < 8, MQ < 40, on top
# of the standard QD/FS thresholds) were chosen specifically because of the
# known GBAP1 pseudogene mis-mapping risk in this gene — see README Step 4.
#
# Requires: conda env `ngs-gba` (gatk4)
# Run from the project root (~/Documents/Projects/NGS-starter)

set -euo pipefail

REF=data/reference/reference_chr1.fa
REGION="1:155204243-155214418"
DB_PATH=results/variants/gba_db
OUT_PREFIX=results/variants/gba_cohort

SAMPLES=("$@")
if [ ${#SAMPLES[@]} -eq 0 ]; then
  echo "Usage: $0 <SAMPLE1> [<SAMPLE2> ...]"
  exit 1
fi

GVCF_ARGS=""
for SAMPLE in "${SAMPLES[@]}"; do
  echo ">>> HaplotypeCaller (GVCF mode) for ${SAMPLE}"
  conda run -n ngs-gba gatk HaplotypeCaller \
    -R ${REF} \
    -I results/aligned/${SAMPLE}.dedup.bam \
    -O results/variants/${SAMPLE}.g.vcf.gz \
    -ERC GVCF \
    -L ${REGION}
  GVCF_ARGS="${GVCF_ARGS} -V results/variants/${SAMPLE}.g.vcf.gz"
done

echo ">>> Joint genotyping across ${#SAMPLES[@]} sample(s)"
rm -rf ${DB_PATH}
conda run -n ngs-gba gatk GenomicsDBImport \
  ${GVCF_ARGS} \
  --genomicsdb-workspace-path ${DB_PATH} \
  -L ${REGION}

SUFFIX="1sample"
[ ${#SAMPLES[@]} -gt 1 ] && SUFFIX="${#SAMPLES[@]}sample"

conda run -n ngs-gba gatk GenotypeGVCFs \
  -R ${REF} \
  -V gendb://${DB_PATH} \
  -O ${OUT_PREFIX}_${SUFFIX}.vcf.gz

echo ">>> Hard-filtering (QD, FS, Depth, MQ)"
conda run -n ngs-gba gatk VariantFiltration \
  -R ${REF} \
  -V ${OUT_PREFIX}_${SUFFIX}.vcf.gz \
  --filter-expression "QD < 2.0" --filter-name "QD2" \
  --filter-expression "FS > 60.0" --filter-name "FS60" \
  --filter-expression "DP < 8" --filter-name "LowDepth" \
  --filter-expression "MQ < 40.0" --filter-name "LowMQ" \
  -O ${OUT_PREFIX}_${SUFFIX}.filtered.vcf.gz

echo ">>> Extracting PASS-only variants"
zcat ${OUT_PREFIX}_${SUFFIX}.filtered.vcf.gz | grep -E "^#|PASS" \
  > ${OUT_PREFIX}_${SUFFIX}.PASS.vcf
conda run -n ngs-gba bgzip -f ${OUT_PREFIX}_${SUFFIX}.PASS.vcf
conda run -n ngs-gba tabix -p vcf ${OUT_PREFIX}_${SUFFIX}.PASS.vcf.gz

echo ">>> Done. PASS variants: ${OUT_PREFIX}_${SUFFIX}.PASS.vcf.gz"
zcat ${OUT_PREFIX}_${SUFFIX}.PASS.vcf.gz | grep -vc "^#"
echo "^ number of PASS variant sites"
