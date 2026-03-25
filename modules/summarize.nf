process SUMMARIZE {

    tag "summarize_context"

    publishDir "${params.outdir}/summary", mode: 'copy'

    input:
    path contigs
    path arg_table
    path plasmid_table
    path intersection_table

    output:
    path "amr_context_summary.txt", emit: summary

    script:
    """
    bash ${projectDir}/scripts/summarize_amr_context.sh \
      $contigs \
      $arg_table \
      $plasmid_table \
      $intersection_table \
      amr_context_summary.txt
    """
}
