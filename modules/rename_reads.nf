process RENAME_READS {

    tag "${reads.simpleName}"

    publishDir "${params.outdir}/renamed_reads", mode: 'copy'

    input:
    path reads

    output:
    path "*.renamed.fastq.gz", emit: renamed_reads

    script:
    """
    python ${projectDir}/scripts/rename_fastq_headers.py \
      $reads \
      ${reads.simpleName}.renamed.fastq.gz
    """
}
