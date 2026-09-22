# Data Provenance

## Sequencing data

**Source:** Genome in a Bottle (GIAB) / NIST — Garvan Institute NA12878 HiSeq Exome dataset

**Directory:** https://ftp-trace.ncbi.nih.gov/ReferenceSamples/giab/data/NA12878/Garvan_NA12878_HG001_HiSeq_Exome/

**Samples used:**

| Sample | Library ID | Lanes | Read length | Platform |
|---|---|---|---|---|
| NIST7035 | TAAGGCGA | L001, L002 | 101bp PE | Illumina HiSeq2500 |
| NIST7086 | CGTACTAG | L001, L002 | 101bp PE | Illumina HiSeq2500 |

Both samples are the same individual (NA12878 / HG001), sequenced from two separate library preparations ("2 vials of NA12878 DNA"), each split across 2 lanes. This was used deliberately as an internal consistency check — genuine variant calls should agree between the two library preps, since they originate from the same source DNA.

**Capture kit:** Illumina Nextera Rapid Capture Exome and Expanded Exome

**Files used:** raw (untrimmed) FASTQ files, adapter-trimmed ourselves using fastp rather than the pre-trimmed files also available in the source directory, so that the QC/trimming pipeline stage could be run and evaluated directly.

## Reference genome build — GRCh37/hg19, not GRCh38

**Important:** this project uses **GRCh37/hg19**, not the more recent GRCh38, because the source dataset's own README explicitly states the accompanying pre-aligned BAM files were "aligned to hg19." To keep coordinates consistent with the dataset's origin and avoid silent build-mismatch errors, the same build was used throughout this pipeline.

**Reference file used:** `Homo_sapiens.GRCh37.dna.chromosome.1.fa` (Ensembl, release 110)
Source: https://ftp.ensembl.org/pub/grch37/release-110/fasta/homo_sapiens/dna/

Only chromosome 1 was used (not the full genome), to keep the analysis laptop-feasible. The full chromosome — not a GBA1-only slice — was used for alignment specifically so that BWA had the sequence of the nearby *GBAP1* pseudogene available, allowing it to correctly disambiguate reads between the real gene and the pseudogene rather than forcing artificially confident but wrong mappings.

## Gene coordinates

**GBA1 (glucocerebrosidase), GRCh37/hg19:** chr1:155,204,243-155,214,418 (minus strand)

Confirmed against GeneCards' GRCh37 gene record. Note: this differs from the GRCh38 coordinates (chr1:155,234,452-155,244,699) that would apply if this project were repeated against the newer build.

## Annotation

**VEP cache:** Ensembl VEP release 105, GRCh37 cache (indexed), downloaded manually from:
https://ftp.ensembl.org/pub/release-105/variation/indexed_vep_cache/homo_sapiens_vep_105_GRCh37.tar.gz

## Splice-impact scoring

**Tools:** SpliceAI and Pangolin, accessed via the SpliceAI Lookup web tool (Broad Institute):
https://spliceailookup.broadinstitute.org/
