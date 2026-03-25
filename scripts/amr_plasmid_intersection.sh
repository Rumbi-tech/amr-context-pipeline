#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <rgi_output.txt> <contig_report.txt> <output.tsv>" >&2
    exit 1
fi

RGI_TAB="$1"
CONTIG_REPORT="$2"
OUT_TSV="$3"

for f in "$RGI_TAB" "$CONTIG_REPORT"; do
    if [[ ! -s "$f" ]]; then
        echo "ERROR: Missing or empty required file: $f" >&2
        exit 2
    fi
done

TMP_AMR="$(mktemp)"
TMP_CLASS="$(mktemp)"

# Extract AMR-positive contig IDs from RGI table
# Prefer ORF_ID if present; fall back to first column.
# If ORF IDs look like contig_12_3, strip the final _<gene_number>
awk -F'\t' '
NR==1 {
    col=0
    for (i=1; i<=NF; i++) {
        h=tolower($i)
        if (h=="orf_id" || h=="orf" || h=="contig" || h=="contig_id") {
            col=i
        }
    }
    if (col==0) col=1
    next
}
NR>1 && $col!="" {
    id=$col
    sub(/ .*/, "", id)
    if (id ~ /_[0-9]+$/) sub(/_[0-9]+$/, "", id)
    print id
}
' "$RGI_TAB" | sort -u > "$TMP_AMR"

# Parse MOB-suite contig_report.txt
# Output: contig_id <tab> class
awk -F'\t' '
BEGIN {
    contig_col=0
    mol_col=0
}
NR==1 {
    for (i=1; i<=NF; i++) {
        h=tolower($i)
        if (h=="contig_id" || h=="contig" || h=="contig_name" || h=="contigname") contig_col=i
        if (h=="molecule_type" || h=="molecule" || h=="type") mol_col=i
    }
    if (contig_col==0) contig_col=1
    next
}
NR>1 {
    id=$contig_col
    mt=(mol_col>0 ? tolower($mol_col) : "unknown")
    cls="unclassified"
    if (mt ~ /plasmid/) cls="plasmid"
    else if (mt ~ /chrom/) cls="chromosome"
    print id "\t" cls
}
' "$CONTIG_REPORT" | sort -u > "$TMP_CLASS"

# Build final AMR/plasmid context table
{
    echo -e "contig_id\tamr_status\tcontext"
    while read -r id; do
        ctx="$(awk -F'\t' -v id="$id" '$1==id {print $2; found=1; exit} END {if (!found) print "unclassified"}' "$TMP_CLASS")"
        echo -e "${id}\tAMR_positive\t${ctx}"
    done < "$TMP_AMR"
} > "$OUT_TSV"

rm -f "$TMP_AMR" "$TMP_CLASS"
