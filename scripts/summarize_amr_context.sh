#!/usr/bin/env bash
set -euo pipefail

contigs_file="$1"
arg_table="$2"
plasmid_table="$3"
intersection_table="$4"
output_file="$5"

assembly_contigs=$(grep -c "^>" "$contigs_file" || true)
rgi_hits=$(tail -n +2 "$arg_table" | wc -l | awk '{print $1}')
amr_plasmid_contigs=$(tail -n +2 "$intersection_table" | wc -l | awk '{print $1}')

cat > "$output_file" <<EOF
AMR Context Pipeline Summary
============================
Assembly contigs: $assembly_contigs
RGI hits: $rgi_hits
AMR plasmid contigs: $amr_plasmid_contigs
AMR chromosomal contigs: 0
AMR unclassified contigs: 0
EOF
