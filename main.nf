nextflow.enable.dsl=2

include { AMR_CONTEXT_PIPELINE } from './workflows/amr_context'

workflow {
    AMR_CONTEXT_PIPELINE()
}
