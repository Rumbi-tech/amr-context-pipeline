process RGI {

    tag "rgi_detection"

    publishDir "${params.outdir}/rgi", mode: 'copy'

    input:
    path proteins

    output:
    path "rgi_output.txt", emit: arg_table

    script:
    """
    export PATH="$HOME/micromamba/envs/amrpipe/bin:\$PATH"

    awk '
    /^>/ { print; next }
    { gsub(/\\*/, "", \$0); print }
    ' $proteins > proteins.clean.faa

    rgi main \
      --input_sequence proteins.clean.faa \
      --output_file rgi_output \
      --input_type protein \
      --clean
    """
}
