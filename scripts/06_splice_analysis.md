# Step 6 — Splice Impact Assessment

Unlike the other steps, this one was **not automated as a script** — it was run
manually through the SpliceAI Lookup web tool, since installing SpliceAI/Pangolin
locally requires a large model download that wasn't justified for scoring
3 variants once.

## Why this step exists

VEP annotated the indel cluster at chr1:155,206,277–155,206,284 (GBA1 intron 8)
as `splice_polypyrimidine_tract_variant` — a **sequence-context** label, not a
functional prediction. To find out whether the variant actually affects splicing,
each component of the (phased) indel cluster was scored individually with two
independent deep-learning splice-effect predictors.

## Tool used

**SpliceAI Lookup** (Broad Institute): https://spliceailookup.broadinstitute.org/

Runs both SpliceAI and Pangolin against a single variant and returns delta
scores for donor/acceptor gain/loss, plus a genome-track visualization.

## Variants scored

For each variant below, the tool was queried with:
- Genome build: **GRCh37**
- Gene: GBA1 (auto-detected)

```
chr1-155206277-A-AC
chr1-155206280-GA-G
chr1-155206284-C-CAGACTCCCCGCAGGTCCGTGAAAGCAGGGGGCTGCATGGACAGGGGCCCACAAGGGTTGAGAGTG
```

## Results

| Variant | SpliceAI max Δ | Pangolin max Δ |
|---|---|---|
| 155206277 A>AC | 0.04 | 0.04 |
| 155206280 GA>G | 0.05 | 0.05 |
| 155206284 C>CAGACT...(66bp) | 0.05 | 0.07 |

All scores fall well below the ~0.2 threshold conventionally used to flag a
splice-altering variant. Two independent models agreeing on "no effect" across
all three linked components of the same haplotype is a reasonably confident
negative result.

## Screenshots used in the README

- `report/images/14_spliceai_track_variant1.png` — genome-track view for the first variant
- `report/images/15_spliceai_track_variant3.png` — genome-track view for the third (largest) variant

## Interpretation

This step is the reason Section 6 of the original project plan (structural ddG
modeling with FoldX/ChimeraX) was replaced with a splice-impact analysis: no
missense/coding variant was found in either sample to run through structural
modeling, so the analysis pivoted to directly testing the one variant with a
plausible (if ultimately unconfirmed) functional angle instead.
