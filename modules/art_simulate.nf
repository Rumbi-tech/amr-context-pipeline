process ART_SIMULATE {

    tag "art_simulation"

    publishDir "${params.outdir}/validation/art", mode: 'copy'

    input:
    path input_fasta

    output:
    path "sim_R1.fq", emit: reads1
    path "sim_R2.fq", emit: reads2

    script:
    """
    export PATH="\$HOME/micromamba/envs/amrpipe/bin:\$PATH"

    art_illumina \
        -ss ${params.art_seq_sys} \
        -i ${input_fasta} \
        -p \
        -l ${params.art_read_length} \
        -f 20 \
        -m ${params.art_frag_mean} \
        -s ${params.art_frag_std} \
        -o sim_

    mv sim_1.fq sim_R1.fq
    mv sim_2.fq sim_R2.fq
    """
}
