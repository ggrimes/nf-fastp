nextflow.enable.dsl=2

params.outdir = "results"
params.fq = "*_{1,2}.fastq.gz"

log.info """\
outdir:         $params.outdir
fastq:    $params.fq
"""


fq_ch=channel.fromFilePairs(params.fq)


workflow {
    FASTP(fq_ch)
    MULTIQC(FASTP.out.json_report.collect())
}


process FASTP {
   tag "${sample_id}"
   publishDir "${params.outdir}", mode: "copy"
   
   
   input:
   tuple val(sample_id),path(fq)
   
   output:
   path "${sample_id}.html", emit: html_report
   path "${sample_id}.fastp.json", emit: json_report
   script:
   """
   fastp -i ${fq[0]} -I ${fq[1]} -h ${sample_id}.html -j ${sample_id}.fastp.json
   """

}

process MULTIQC {

   publishDir "${params.outdir}", mode: "copy"
   
   
   input:
   path json
   
   output:
   path "*", emit: mqc
   
   script:
   """
   multiqc .
   """
}

workflow.onComplete {
    println "Pipeline completed at: $workflow.complete"
    println "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
}
