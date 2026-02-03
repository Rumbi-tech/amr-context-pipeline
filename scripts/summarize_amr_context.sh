#!/usr/bin/env bash
set -euo pipefail

OUT="runs/amr_context_summary.tsv"

echo -e "barcode\tamr_total\tchromosomal\tplasmid\tunclassified" > "$OUT"

for BARCODE in barcode03 barcode04; do
    BASE="runs/${BARCODE}/summary"

    TOTAL=$(wc -l < "${BASE}/amr_contigs.txt")
    CHR=$(wc -l < "${BASE}/amr_chromosomal_contigs.txt" 2>/dev/null || echo 0)
    PLA=$(wc -l < "${BASE}/amr_plasmid_contigs.txt" 2>/dev/null || echo 0)
    UNK=$(wc -l < "${BASE}/amr_unclassified_contigs.txt" 2>/dev/null || echo 0)

    echo -e "${BARCODE}\t${TOTAL}\t${CHR}\t${PLA}\t${UNK}" >> "$OUT"
done

echo "Summary table written to $OUT"

