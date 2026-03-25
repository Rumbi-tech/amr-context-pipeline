process PRODIGAL {

    tag "prodigal_prediction"

    publishDir "${params.outdir}/prodigal", mode: 'copy'

    input:
    path contigs

    output:
    path "proteins.faa", emit: proteins
    path "genes.gff", emit: gff

    script:
    """
    prodigal \
      -i $contigs \
      -a proteins.faa \
      -f gff \
      -o genes.gff
    """
}
