include { RENAME_READS }       from '../modules/rename_reads'
include { FLYE }               from '../modules/flye'
include { ART_SIMULATE }       from '../modules/art_simulate'
include { MEGAHIT_ASSEMBLY }   from '../modules/megahit'
include { PRODIGAL }           from '../modules/prodigal'
include { RGI }                from '../modules/rgi'
include { MOBSUITE }           from '../modules/mobsuite'
include { AMR_INTERSECTION }   from '../modules/amr_intersection'
include { SUMMARIZE }          from '../modules/summarize'

workflow AMR_CONTEXT_PIPELINE {

    if( params.mode == "validation" ) {
        if( !params.validation_fasta ) {
            error "Validation mode requires --validation_fasta"
        }

        validation_fasta_ch = Channel.fromPath(params.validation_fasta, checkIfExists: true)

        ART_SIMULATE(validation_fasta_ch)
        MEGAHIT_ASSEMBLY(ART_SIMULATE.out.reads1, ART_SIMULATE.out.reads2)

        contigs_ch = MEGAHIT_ASSEMBLY.out.contigs
    }
    else if( params.contigs ) {
        contigs_ch = Channel.fromPath(params.contigs, checkIfExists: true)
    }
    else if( params.reads ) {
        reads_ch = Channel.fromPath(params.reads, checkIfExists: true)
        RENAME_READS(reads_ch)
        pooled_reads_ch = RENAME_READS.out.renamed_reads.collect()
        FLYE(pooled_reads_ch)
        contigs_ch = FLYE.out.contigs
    }
    else {
        error "Please provide either --reads, --contigs, or use --mode validation with --validation_fasta"
    }

    PRODIGAL(contigs_ch)

rgi_res = RGI(PRODIGAL.out.proteins)

mob_res = MOBSUITE(contigs_ch)

intersection_res = AMR_INTERSECTION(
    rgi_res.arg_table,
    mob_res.contig_report
)

SUMMARIZE(
    contigs_ch,
    rgi_res.arg_table,
    mob_res.contig_report,
    intersection_res.intersection_table
)
}
