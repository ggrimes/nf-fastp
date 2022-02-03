nextflow.enable.dsl=2

params.outdir = "results"
params.fq = "*_{1,2}.fastq.gz"

log.info """\
outdir:         $params.outdir
fastq:    $params.fq
"""


fq_ch=channel.fromFilePairs(params.fq)


workflow {
    FASTP(bam_ch)
}


process FASTP {
   tag "${sample_id}"
   publishDir "${params.outdir}", mode: "copy"
   
   
   input:
   tuple val(sample_id),path(fq)
   
   output:
   path "${sample_id}.html", emit: report
   
   script:
   """
   fastp -i ${fq[0]} -I ${fq[1]} -o out.R1.fq.gz -O out.R2.fq.gz -h ${sample_id}.html
   """

}
