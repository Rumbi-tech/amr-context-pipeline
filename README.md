cd ~/amr-context-pipeline

cat > README.md <<'EOF'
# AMR Context Pipeline (RGI + MOB-suite)

## Project Abstract
Antimicrobial resistant (AMR) bacteria are widespread in natural environments and pose a growing threat to human and ecosystem health. AMR can arise through two primary mechanisms: 1) de novo mutations in previously susceptible bacterial genomes and 2) horizontal transfer of AMR genes between species often via mobile genetic elements such as plasmids. This project aims to develop a comprehensive bioinformatics pipeline to evaluate the relative importance of these mechanisms within bacterial communities. Using a combination of long-read and short-read metagenomic sequencing data, the pipeline assembles and aligns metagenomes from raw reads, identifies AMR genes using curated resistance databases, and determines the genomic context of these genes, distinguishing chromosomal integration from mobile genetic element association. The pipeline is first validated using simulated datasets to assess performance and accuracy and is subsequently applied to metagenomic data from environmental bacterial communities. By the end of the project, the goal is to produce a reproducible and interpretable workflow capable of linking AMR genes to their genomic context, thereby improving understanding of AMR emergence and dissemination in environmental systems.

---

## Pipeline Overview

This repository contains a reproducible workflow that:

1. **Assembles long-read metagenomic data** into contigs (Flye)
2. **Annotates AMR genes** on assembled contigs using **RGI (CARD database)**
3. **Classifies contigs** as plasmid/chromosome/unclassified using **MOB-suite (mob_recon)**
4. **Resolves AMR genomic context** by intersecting:
   - AMR-positive contigs from RGI
   - Contig mobility classification from MOB-suite
5. **Summarizes + visualizes** AMR results (TSVs + publication-ready plots)

> Important distinction:
> - **RGI detects AMR genes** (which contigs contain resistance genes).
> - **MOB-suite classifies contigs** (plasmid-associated vs chromosomal vs unclassified).
> - This pipeline **integrates both** to infer AMR genomic context.

---

## Inputs and Outputs

### Inputs (typical run)
- Long-read FASTQ(.gz) files (e.g., Nanopore)
- Optional: other datasets for validation (e.g., simulated)

### Outputs (cleaned repository version)
For each barcode, we keep a compact, shareable set of outputs under:

- `runs/<barcode>/flye_final/assembly.fasta` (final contigs used downstream)
- `runs/<barcode>/rgi/` (AMR calls)
- `runs/<barcode>/mob/` (contig classification)
- `runs/<barcode>/summary/` (aggregated tables + plots + AMR contig FASTA)

We intentionally do **not** version-control:
- Raw reads (`*.fastq.gz`)
- Large intermediate assembly folders (e.g., Flye step directories)
- Large databases (CARD, MOB-suite DBs, etc.)

Instead, we provide environment setup instructions so anyone can recreate the run.

---

## Tools Used
- **Flye**: long-read assembly
- **RGI**: AMR detection using **CARD**
- **MOB-suite (mob_recon)**: plasmid/chromosome contig classification
- Custom scripts: summarization, plotting, and AMR–plasmid intersection

---

## Step-by-step Workflow

### 1) Assembly (Flye)
- **Input:** long-read FASTQs
- **Output:** assembled contigs (`assembly.fasta`)

### 2) AMR Annotation (RGI / CARD)
- **Tool:** RGI (CARD database)
- **Input:** assembled contigs
- **Output:** AMR annotations (`*_rgi.txt`, `*_rgi.json`)

### 3) Plasmid/Chromosome Classification (MOB-suite)
- **Tool:** MOB-suite (`mob_recon`)
- **Input:** assembled contigs
- **Outputs:**
  - `chromosome.fasta`
  - `contig_report.txt`
  - `mge.report.txt`

### 4) AMR–Plasmid Intersection (Genomic Context Resolution)
- **Custom script:** `scripts/amr_plasmid_intersection.sh`
- **Purpose:** Integrate RGI + MOB-suite outputs to determine genomic context of AMR-positive contigs.
- **Outputs (written into each barcode summary dir):**
  - `amr_plasmid_contigs.txt`
  - `amr_chromosomal_contigs.txt`
  - `amr_unclassified_contigs.txt`
  - `amr_contig_context.tsv`
  - `amr_context_counts.tsv`

Example:
```bash
scripts/amr_plasmid_intersection.sh \
  -r runs/barcode04/rgi/barcode04_rgi.txt \
  -m runs/barcode04/mob/contig_report.txt \
  -o runs/barcode04/summary

