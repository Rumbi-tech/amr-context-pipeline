# Pipeline Validation (Plasmid Positive Control)

This folder contains a controlled validation experiment showing that the AMR Context Pipeline can detect plasmid-associated antimicrobial resistance genes (ARGs).

## Methodology
RefSeq plasmids (Downloaded reference plasmid sequences from the NCBI RefSeq plasmid release)
      ↓
ARG detection (RGI) (Identified ARG-positive plasmids )
      ↓
Simulate reads (ART) (Identified ARG-positive plasmids)
      ↓
Assembly (MEGAHIT) (Assembled reads)
      ↓
ARG detection (RGI) 
      ↓
Plasmid classification (MOB-suite) 
      ↓
ARG–plasmid intersection (Intersected ARG-bearing contigs with plasmid-classified contigs)

## Key results (this run)
- Assembly contigs: **37**
- ARG hits (RGI): **23**
- Plasmid-associated ARG contigs: **14**
- Representative genes: CTX-M-15, sul1, tet(45), aadA, AAC/ANT, qacG, dfrA12

## How to run

```bash
bash scripts/validation/run_plasmid_validation_optionA.sh
Outputs

validation/figures/ - workflow figure
validation/reports/ - PDF summary report
validation/outputs/ - generated outputs (not committed)
