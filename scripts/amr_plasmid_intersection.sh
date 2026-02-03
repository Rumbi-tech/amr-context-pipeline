#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# AMR–Plasmid Intersection (RGI + MOB-suite genomic context)
#
# Inputs (per barcode):
#   runs/<barcode>/summary/amr_contigs.txt        (AMR-positive contig IDs; one per line)
#   runs/<barcode>/mob/contig_report.txt          (MOB-suite contig classifications)
#   runs/<barcode>/mob/chromosome.fasta           (MOB-suite chromosomal contigs FASTA)
#
# Outputs (written to runs/<barcode>/summary/ ):
#   amr_plasmid_contigs.txt
#   amr_chromosomal_contigs.txt
#   amr_unclassified_contigs.txt
#   amr_contig_context.tsv
#   amr_context_counts.tsv
# ------------------------------------------------------------

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <barcode> [runs_dir]"
  echo "Example: $0 barcode03"
  echo "Example: $0 barcode04 runs"
  exit 1
fi

BC="$1"
RUNS_DIR="${2:-runs}"

BASE="${RUNS_DIR}/${BC}"
SUMMARY_DIR="${BASE}/summary"
MOB_DIR="${BASE}/mob"

AMR_LIST="${SUMMARY_DIR}/amr_contigs.txt"
CONTIG_REPORT="${MOB_DIR}/contig_report.txt"
CHROM_FASTA="${MOB_DIR}/chromosome.fasta"

OUT_PLASMID="${SUMMARY_DIR}/amr_plasmid_contigs.txt"
OUT_CHR="${SUMMARY_DIR}/amr_chromosomal_contigs.txt"
OUT_UNK="${SUMMARY_DIR}/amr_unclassified_contigs.txt"
OUT_CONTEXT="${SUMMARY_DIR}/amr_contig_context.tsv"
OUT_COUNTS="${SUMMARY_DIR}/amr_context_counts.tsv"

# --- sanity checks ---
for f in "$AMR_LIST" "$CONTIG_REPORT"; do
  if [[ ! -s "$f" ]]; then
    echo "ERROR: Missing or empty required file: $f" >&2
    exit 2
  fi
done

mkdir -p "$SUMMARY_DIR"

# --- load AMR contigs into a temp normalized list (unique) ---
TMP_AMR="$(mktemp)"
grep -v '^\s*$' "$AMR_LIST" | sed 's/\r$//' | sort -u > "$TMP_AMR"

# --- extract chromosomal contig IDs from chromosome.fasta (if present) ---
TMP_CHR="$(mktemp)"
if [[ -s "$CHROM_FASTA" ]]; then
  grep '^>' "$CHROM_FASTA" | sed 's/^>//' | awk '{print $1}' | sort -u > "$TMP_CHR"
else
  # It's okay if chromosome.fasta isn't present; we'll rely on contig_report only.
  : > "$TMP_CHR"
fi

# --- parse contig_report.txt to get plasmid/chromosome calls ---
# We try to detect columns by header names (contig_id / contig_name / molecule_type)
TMP_PLASMID_FROM_REPORT="$(mktemp)"
TMP_CHR_FROM_REPORT="$(mktemp)"
TMP_UNK_FROM_REPORT="$(mktemp)"

awk -F'\t' '
BEGIN{
  contig_col=0; mol_col=0;
}
NR==1{
  # Find header indices (case-insensitive)
  for(i=1;i<=NF;i++){
    h=tolower($i)
    if(h=="contig_id" || h=="contig" || h=="contig_name" || h=="contigname"){ contig_col=i }
    if(h=="molecule_type" || h=="molecule" || h=="type"){ mol_col=i }
  }
  # Fallbacks
  if(contig_col==0) contig_col=1
  # If no molecule_type column found, try a common alternative seen in some reports:
  # if still 0, we cannot classify from report.
  next
}
NR>1{
  c=$contig_col
  mt=(mol_col>0 ? tolower($mol_col) : "unknown")

  # Normalize a few common molecule_type values
  if(mt ~ /plasmid/) print c "\tplasmid"
  else if(mt ~ /chrom/) print c "\tchromosome"
  else if(mt ~ /unclassified|unknown|other|ambiguous|no\_hit|null|na|n\/a/) print c "\tunclassified"
  else if(mol_col==0) print c "\tunclassified"
  else print c "\tunclassified"
}
' "$CONTIG_REPORT" \
| awk -F'\t' '{
    id=$1; cls=$2
    if(cls=="plasmid") print id
    else if(cls=="chromosome") print id
    else print id
  }' >/dev/null

# Now actually split into separate files using the same parsing logic but outputting to 3 streams
awk -F'\t' -v P="$TMP_PLASMID_FROM_REPORT" -v C="$TMP_CHR_FROM_REPORT" -v U="$TMP_UNK_FROM_REPORT" '
BEGIN{ contig_col=0; mol_col=0; }
NR==1{
  for(i=1;i<=NF;i++){
    h=tolower($i)
    if(h=="contig_id" || h=="contig" || h=="contig_name" || h=="contigname"){ contig_col=i }
    if(h=="molecule_type" || h=="molecule" || h=="type"){ mol_col=i }
  }
  if(contig_col==0) contig_col=1
  next
}
NR>1{
  id=$contig_col
  mt=(mol_col>0 ? tolower($mol_col) : "unknown")

  if(mt ~ /plasmid/) print id >> P
  else if(mt ~ /chrom/) print id >> C
  else print id >> U
}
END{
  # nothing
}
' "$CONTIG_REPORT"

sort -u -o "$TMP_PLASMID_FROM_REPORT" "$TMP_PLASMID_FROM_REPORT" 2>/dev/null || true
sort -u -o "$TMP_CHR_FROM_REPORT" "$TMP_CHR_FROM_REPORT" 2>/dev/null || true
sort -u -o "$TMP_UNK_FROM_REPORT" "$TMP_UNK_FROM_REPORT" 2>/dev/null || true

# --- Combine chromosome calls: chromosome.fasta is authoritative if present ---
# Final CHR set = (chr from fasta) UNION (chr from report)
TMP_CHR_FINAL="$(mktemp)"
cat "$TMP_CHR" "$TMP_CHR_FROM_REPORT" | sort -u > "$TMP_CHR_FINAL"

# Final PLASMID set = plasmid from report MINUS chromosomal set (avoid contradictions)
TMP_PLASMID_FINAL="$(mktemp)"
comm -23 <(sort -u "$TMP_PLASMID_FROM_REPORT") <(sort -u "$TMP_CHR_FINAL") > "$TMP_PLASMID_FINAL"

# --- Intersect AMR list with each context category ---
# AMR ∩ plasmid
comm -12 <(sort -u "$TMP_AMR") <(sort -u "$TMP_PLASMID_FINAL") > "$OUT_PLASMID"
# AMR ∩ chromosome
comm -12 <(sort -u "$TMP_AMR") <(sort -u "$TMP_CHR_FINAL") > "$OUT_CHR"

# Unclassified AMR = AMR minus (plasmid ∪ chromosome)
TMP_CLASSIFIED="$(mktemp)"
cat "$OUT_PLASMID" "$OUT_CHR" | sort -u > "$TMP_CLASSIFIED"
comm -23 <(sort -u "$TMP_AMR") <(sort -u "$TMP_CLASSIFIED") > "$OUT_UNK"

# --- Build context table ---
# columns: contig_id, amr_status, context
{
  echo -e "contig_id\tamr_status\tcontext"
  while read -r id; do
    ctx="unclassified"
    if grep -qx "$id" "$OUT_PLASMID"; then ctx="plasmid"
    elif grep -qx "$id" "$OUT_CHR"; then ctx="chromosome"
    fi
    echo -e "${id}\tAMR_positive\t${ctx}"
  done < "$TMP_AMR"
} > "$OUT_CONTEXT"

# --- Counts file (key\tvalue) ---
tot_amr=$(wc -l < "$TMP_AMR" | tr -d ' ')
pl=$(wc -l < "$OUT_PLASMID" | tr -d ' ')
ch=$(wc -l < "$OUT_CHR" | tr -d ' ')
un=$(wc -l < "$OUT_UNK" | tr -d ' ')

{
  echo -e "total_amr_contigs\t${tot_amr}"
  echo -e "amr_plasmid_contigs\t${pl}"
  echo -e "amr_chromosomal_contigs\t${ch}"
  echo -e "amr_unclassified_contigs\t${un}"
} > "$OUT_COUNTS"

echo "✅ Done: ${BC}"
echo "  - $OUT_PLASMID"
echo "  - $OUT_CHR"
echo "  - $OUT_UNK"
echo "  - $OUT_CONTEXT"
echo "  - $OUT_COUNTS"

# cleanup temp files
rm -f "$TMP_AMR" "$TMP_CHR" "$TMP_CHR_FROM_REPORT" "$TMP_CHR_FINAL" \
      "$TMP_PLASMID_FROM_REPORT" "$TMP_PLASMID_FINAL" "$TMP_UNK_FROM_REPORT" \
      "$TMP_CLASSIFIED"

