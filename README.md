# AMR Context Pipeline

A reproducible **Nextflow DSL2 bioinformatics pipeline** for detecting antimicrobial resistance (AMR) genes and determining their genomic context (plasmid vs chromosomal) from metagenomic sequencing data.

---

## 🔬 Abstract

Antimicrobial resistant (AMR) bacteria are widespread in natural environments and pose a growing threat to human and ecosystem health. AMR can arise through two primary mechanisms:  
1) *De novo* mutations in previously susceptible bacterial genomes  
2) Horizontal transfer of AMR genes between species, often mediated by mobile genetic elements such as plasmids  

This project presents a comprehensive bioinformatics pipeline designed to evaluate the relative importance of these mechanisms within bacterial communities. Using a combination of long-read and short-read metagenomic sequencing data, the pipeline assembles metagenomes from raw reads, identifies AMR genes using curated resistance databases, and determines the genomic context of these genes, distinguishing chromosomal integration from mobile genetic element association.  

The pipeline is first validated using simulated datasets to assess performance and accuracy and is subsequently applied to environmental metagenomic samples. The resulting workflow enables reproducible and interpretable analysis linking AMR genes to their genomic context, thereby improving understanding of AMR emergence and dissemination in environmental systems.  

This project is conducted under the supervision of **Professor Susan Bailey**.

---

## 🎯 Objective

To determine whether antimicrobial resistance genes are:
- Chromosomally encoded (*de novo* mutation-driven)
- Plasmid-associated (horizontal gene transfer)

---

## ⚙️ Workflow Overview

1. **Read Simulation (optional)** – ART  
2. **Assembly** – MEGAHIT / Flye  
3. **Gene Prediction** – Prodigal  
4. **AMR Detection** – RGI (CARD database)  
5. **Plasmid Classification** – MOB-suite  
6. **AMR-Plasmid Intersection Analysis**  
7. **Summary Report Generation**

---

## 🧱 Pipeline Structure
├── main.nf
├── nextflow.config
├── modules/
├── workflows/
├── scripts/
├── validation/

---

## 🧠 Tools and Technologies

- Nextflow DSL2  
- MEGAHIT  
- Flye  
- Prodigal  
- RGI (CARD database)  
- MOB-suite  
- ART (simulation)  

---

## 🚀 Usage

### Clone the repository

```bash
git clone https://github.com/Rumbi-tech/amr-context-pipeline.git
cd amr-context-pipeline


---

Run the pipeline
nextflow run main.nf

📊 Validation Results

The pipeline was validated using a RefSeq plasmid dataset:

Metric	Value
Assembly contigs	591
RGI hits	28
AMR plasmid contigs	24
AMR chromosomal contigs	0

These results confirm successful detection of plasmid-associated AMR genes, demonstrating correct pipeline functionality.

🌍 Scientific Significance

This pipeline provides a framework for:

Distinguishing AMR origin mechanisms

Identifying horizontal gene transfer events

Studying AMR dissemination in environmental systems

It supports research in:

Environmental microbiology

Public health

One Health

🔁 Reproducibility

Implemented in Nextflow DSL2, ensuring:

Modular workflow design

Scalability on HPC systems

Full reproducibility of analyses

👩🏽‍💻 Author

Rumbidzai Mushamba
M.S. Applied Data Science – Clarkson University

📄 License

MIT License
