![License](https://img.shields.io/badge/license-MIT-blue)
![Workflow](https://img.shields.io/badge/workflow-bioinformatics-green)
![AMR](https://img.shields.io/badge/focus-AMR-red)

# AMR Context Pipeline (RGI + MOB-suite)


git add README.md
git commit -m "Finalize project README with AMR-plasmid context workflow"
# AMR Context Pipeline 

## Project Abstract

Antimicrobial resistant (AMR) bacteria are widespread in natural environments and pose a growing threat to human and ecosystem health. AMR can arise through two primary mechanisms: (1) de novo mutations in previously susceptible bacterial genomes and (2) horizontal transfer of AMR genes between species, often via mobile genetic elements such as plasmids.  

This project aims to develop a comprehensive bioinformatics pipeline to evaluate the relative importance of these mechanisms within bacterial communities. Using a combination of long-read and short-read metagenomic sequencing data, the pipeline assembles and aligns metagenomes from raw reads, identifies AMR genes using curated resistance databases, and determines the genomic context of these genes, distinguishing chromosomal integration from mobile genetic element association.  

The pipeline is first validated using simulated datasets to assess performance and accuracy and is subsequently applied to metagenomic data from environmental bacterial communities. By the end of the project, the goal is to produce a reproducible and interpretable workflow capable of linking AMR genes to their genomic context, thereby improving understanding of AMR emergence and dissemination in environmental systems.

---

## Pipeline Overview

This repository contains a reproducible workflow that:

1. **Assembles long-read metagenomic data** into contigs using **Flye**
2. **Annotates AMR genes** on assembled contigs using **RGI (CARD database)**
3. **Classifies contigs** as plasmid-associated, chromosomal, or unclassified using **MOB-suite (mob_recon)**
4. **Resolves AMR genomic context** by intersecting:
   - AMR-positive contigs (RGI)
   - Contig mobility classifications (MOB-suite)
5. **Summarizes and visualizes** AMR results with tables and publication-ready figures

### Important distinction
- **RGI** answers: *Which contigs contain AMR genes?*
- **MOB-suite** answers: *Are contigs plasmid-associated or chromosomal?*
- **This pipeline integrates both** to infer **AMR genomic context**

---

## Tools Used

| Step | Tool | Purpose |
|-----|------|--------|
| Assembly | Flye | Long-read metagenome assembly |
| AMR annotation | RGI (CARD) | Detect AMR genes |
| Mobility classification | MOB-suite (mob_recon) | Plasmid vs chromosome |
| Context resolution | Custom bash script | AMR-plasmid intersection |
| Visualization | Python | Summary figures |

---

## AMR-Plasmid Intersection (Core Contribution)

A custom script resolves the genomic context of AMR genes by intersecting RGI and MOB-suite outputs:

**Script**
scripts/amr_plasmid_intersection.sh

**Inputs**
- `runs/<barcode>/rgi/*.rgi.txt`
- `runs/<barcode>/mob/contig_report.txt`
- `runs/<barcode>/mob/chromosome.fasta`

**Outputs**
- `amr_plasmid_contigs.txt`
- `amr_chromosomal_contigs.txt`
- `amr_unclassified_contigs.txt`
- `amr_contig_context.tsv`
- `amr_context_counts.tsv`

This step determines whether AMR genes are:
- Chromosomally encoded (de novo mutation signal)
- Plasmid-associated (horizontal gene transfer signal)

---

## Summary Table (Counts per Barcode)

A global summary table aggregates AMR context counts across samples:

**File**
runs/amr_context_summary.tsv

**Columns**
- `barcode`
- `total_amr_contigs`
- `amr_plasmid_contigs`
- `amr_chromosomal_contigs`
- `amr_unclassified_contigs`

**Example**

barcode total_amr_contigs amr_plasmid_contigs amr_chromosomal_contigs amr_unclassified_contigs
barcode03 7 0 7 0
barcode04 6 0 6 0

---

## Outputs (Clean GitHub Version)

For each barcode, the repository retains a **compact, shareable output set**:

runs/<barcode>/
├── flye_final/
│ └── assembly.fasta
├── rgi/
│ ├── <barcode>_rgi.txt
│ └── <barcode>_rgi.json
├── mob/
│ ├── contig_report.txt
│ └── mge.report.txt
└── summary/
├── amr_by_drug_class.tsv
├── amr_by_mechanism.tsv
├── amr_by_molecule_type.tsv
├── amr_contigs.fasta
├── amr_contig_context.tsv
├── amr_context_counts.tsv
└── figures/


---

## What Is *Not* Tracked (and Why)

The following are excluded via `.gitignore` to keep the repository lightweight and reproducible:

- Raw sequencing reads (`*.fastq.gz`)
- Intermediate Flye directories (`00-assembly/`, `10-consensus/`, etc.)
- Large reference databases (CARD, MOB-suite DBs)
- Temporary and log files

These resources are **recreated at runtime** and should not be version-controlled.

---

## Reproducibility and Future Work

- Designed for **HPC environments**
- Conda/Mamba environments provided
- Directory structure is **Nextflow-ready**
- Future work includes:
  - Full Nextflow implementation
  - Automated multi-sample execution
  - Integration of short-read polishing
  - Quantitative comparison of HGT vs mutation signals

---

## Author

**Rumbidzai N. Mushamba**  
Applied Data Science  
Clarkson University







