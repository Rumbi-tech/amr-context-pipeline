process FLYE {

    tag "flye_assembly"

    publishDir "${params.outdir}/flye", mode: 'copy'

    input:
    path reads

    output:
    path "assembly.fasta", emit: contigs

    script:
    """
    flye \
      --nano-raw ${reads.join(' ')} \
      --out-dir flye_out \
      --threads ${task.cpus}

    cp flye_out/assembly.fasta assembly.fasta
    """
}
