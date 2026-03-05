# Pipeline Validation (Plasmid Positive Control)

This folder contains a controlled validation experiment showing that the AMR Context Pipeline can detect plasmid-associated antimicrobial resistance genes (ARGs).

## What we did
- Downloaded reference plasmid sequences from the NCBI RefSeq plasmid release
- Identified ARG-positive plasmids (Prodigal -> RGI/CARD)
- Simulated Illumina paired-end reads (ART)
- Assembled reads (MEGAHIT)
- Detected ARGs (Prodigal -> RGI/CARD)
- Classified plasmid contigs (MOB-suite)
- Intersected ARG-bearing contigs with plasmid-classified contigs

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
