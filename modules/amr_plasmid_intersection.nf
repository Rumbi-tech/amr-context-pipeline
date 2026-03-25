script:
"""
# Extract plasmid contigs
awk '\$2=="plasmid" {print \$5}' ${mobsuite_report} > plasmid_contigs.txt

# Extract AMR contigs (first column, skip header)
cut -f1 ${rgi_file} | tail -n +2 > amr_contigs.txt

# Find intersection
grep -F -f plasmid_contigs.txt amr_contigs.txt > amr_plasmid_hits.txt

# Add header
echo -e "contig_id" > amr_plasmid_intersection.tsv
cat amr_plasmid_hits.txt >> amr_plasmid_intersection.tsv
"""
