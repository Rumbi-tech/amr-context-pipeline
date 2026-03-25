process MOBSUITE {

    tag "mobsuite_classification"

    publishDir "${params.outdir}/mobsuite", mode: 'copy', pattern: "contig_report.txt"
    publishDir "${params.outdir}/mobsuite/full_output", mode: 'copy', pattern: "mobsuite_out/*"

    input:
    path contigs

    output:
    path "contig_report.txt", emit: contig_report
    path "mobsuite_out/*", optional: true, emit: mobsuite_files

    script:
    """
    export PATH="\$HOME/micromamba/envs/mobsuite_env/bin:\$PATH"

    mob_recon \
        --infile ${contigs} \
        --outdir mobsuite_out

    cp mobsuite_out/contig_report.txt contig_report.txt
    """
}
