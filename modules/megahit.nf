process MEGAHIT_ASSEMBLY {

    tag "megahit_assembly"

    publishDir "${params.outdir}/${params.mode}/megahit", mode: 'copy'

    input:
    path reads1
    path reads2

    output:
    path "assembly.fasta", emit: contigs

    script:
    """
    export PATH="$HOME/micromamba/envs/amrpipe/bin:\$PATH"

    megahit \
      -1 $reads1 \
      -2 $reads2 \
      -o megahit_out

    cp megahit_out/final.contigs.fa assembly.fasta
    """
}
