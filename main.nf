#!/usr/bin/env nextflow
nextflow.enable.dsl=1
// If the user uses the --help flag, print the help text below
params.help = false

// Function which prints help message text
def helpMessage() {
    log.info"""
    Run the mappping pipeline for a given ref, short and long read dataset

    Required Arguments:
      --project       name        A project name
      --seedfile      file        A file contains sample_name,reads1,reads2
      --outdir        path        Output s3 path

    Options:
      -profile        docker      run locally


    """.stripIndent()
}

// Show help message if the user specifies the --help flag at runtime
if (params.help){
    // Invoke the function above which prints the help message
    helpMessage()
    // Exit out and do not run anything else
    exit 0
}

if (params.outdir  == "null") {
	exit 1, "Missing the output path"
}
if (params.project == "null") {
	exit 1, "Missing the project name"
}
Channel
  .fromPath(params.seedfile)
  .ifEmpty { exit 1, "Cannot find the input seedfile" }

/*
 * Defines the pipeline inputs parameters (giving a default value for each for them)
 * Each of the following parameters can be specified as command line options
 */

def outdir1  = "${params.outdir}"
println outdir1


Channel
 .fromPath(params.seedfile)
 .ifEmpty { exit 1, "Cannot find any seed file matching: ${params.seedfile}." }
 .splitCsv(header: ['sample', 'reads1', 'reads2'], sep: ',', skip: 1)
 .map{ row -> tuple(row.sample, row.reads1, row.reads2)}
 .set { seedfile_ch }


 process copy_reads {
     tag "$id"

     container params.container

     publishDir "${params.outdir}/${params.project}/fastq/", mode:'copy'

     input:
     tuple val(id), path(read1), path(read2) from seedfile_ch

     output:
     path "*_1.fq.gz" into r1_ch
     //path "*_2.fq.gz" into r2_ch

     script:
     """
     if [[ $read1 = ${id}_1.fq.gz ]]
     then
       echo "keep files"
     else
       echo "copy files"
       mv $read1 ${id}_1.fq.gz
       mv $read2 ${id}_2.fq.gz
       sleep 1
     fi
     """
 }
 Channel
   .fromPath("${params.outdir}/${params.project}/fastq/", type: 'dir')
   .set{ coptr_dir_ch }
/*
Calculate ptr in 3 steps
    # Map reads
    # Extract read positions
    # Estimate ptrs
*/
 process coptr {
     tag "${params.project}"

     container params.container
     cpus { 16 * task.attempt }
     memory { 32.GB * task.attempt }

     errorStrategy { task.exitStatus in 137..140 ? 'retry' : 'terminate' }
     maxRetries 2

     publishDir "${params.outdir}/${params.project}", mode:'copy'

     input:
     file 'read1-dir/*' from r1_ch.toSortedList()
     file 'reads-dir/*' from coptr_dir_ch.toSortedList()

     output:
     path "*_hCom2_coptr.csv"
     path "plots-dir/*"

     script:
     """
     mkdir bam-dir
     coptr map --threads 16  /mnt/efs/databases/CoPTR/hcom2-index/hcom2 read1-dir bam-dir

     mkdir coverage-maps
     coptr extract bam-dir coverage-maps

     mkdir plots-dir
     coptr estimate --plot plots-dir coverage-maps ${params.project}_hCom2_coptr.csv
     """
 }
