# genome-metagenome-amp-prediction

Reproducible Bash pipeline for antimicrobial peptide (AMP) prediction from genome and metagenome FASTA assemblies using Macrel.

---

## Overview

This repository contains a batch Bash pipeline designed to run Macrel on multiple genome or metagenome FASTA files and generate a consolidated table of antimicrobial peptide (AMP) predictions.

The pipeline:

- Iterates over all `.fasta` files in the input directory
- Executes `macrel contigs`
- Decompresses prediction outputs
- Consolidates all predictions into a single tab-delimited file

---

## Requirements

- Linux / macOS
- Bash
- Macrel installed and available in PATH
- gzip

Install Macrel (example using conda):

```bash
conda install -c bioconda macrel

##Verify installation
