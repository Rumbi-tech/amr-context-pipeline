process AMR_INTERSECTION {

    tag "amr_plasmid_intersection"

    publishDir "${params.outdir}/intersection", mode: 'copy'

    input:
    path arg_table
    path contig_report

    output:
    path "ARG_contigs.txt", emit: arg_contigs
    path "plasmid_contigs.txt", emit: plasmid_contigs
    path "amr_plasmid_intersection.tsv", emit: intersection_table

    script:
    """
    awk 'NR>1 {print \$1}' ${arg_table} | cut -d "_" -f1-2 | sort | uniq > ARG_contigs.txt

    awk 'NR>1 && \$2=="plasmid" {print \$5}' ${contig_report} | sort | uniq > plasmid_contigs.txt

    {
        head -n 1 ${arg_table}
        grep -F -f plasmid_contigs.txt ${arg_table} || true
    } > amr_plasmid_intersection.tsv
    """
}
