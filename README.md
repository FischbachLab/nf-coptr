README
====================

## CoPTR is a tool for estimating peak-to-trough ratios from metagenomic sequencing.

## Reference:

 	[title](https://github.com/tyjo/coptr/)

 	[title](https://coptr.readthedocs.io/en/latest/tutorial.html)

### Note that only hCom2 database is built for CoPTR. For paired end sequencing, it is recommend to only map reads from a single mate-pair.

## Seedfile example
### Note that the seedfile is a CSV (comma-separated values) file with header
### The format of the seedfile is sample_name,short_R1,short_R2

```{bash}
sampleName,R1,R2
Plate1_MITI-001-Mouse_A10_W8_6-1_S394,s3://maf-sequencing/Illumina/221213_A01679_0069_BHLLVHDSX5/Allison_Weakley/MITI-001-BackfillAnalysis/Plate1_MITI-001-Mouse_A10_W8_6-1_S394_R1.fastq.gz,s3://maf-sequencing/Illumina/221213_A01679_0069_BHLLVHDSX5/Allison_Weakley/MITI-001-BackfillAnalysis/Plate1_MITI-001-Mouse_A10_W8_6-1_S394_R2.fastq.gz
```

## A sample batch submission script

```{bash}
aws batch submit-job \
  --job-name nf-coptr \
  --job-queue priority-maf-pipelines \
  --job-definition nextflow-production \
  --container-overrides command="s3://nextflow-pipelines/nf-coptr, \
"--project", "TEST", \
"--seedfile", "s3://genomics-workflow-core/Results/coptr/230523_seedfile.tsv", \
"--outdir", "s3://genomics-workflow-core/Results/coptr" "
```

### The output is a CSV file where, the rows are reference genomes, and the columns are samples. Each entry is the estimated log2 PTR.
### The final output file path:
```{bash}
s3://genomics-workflow-core/Results/coptr/TEST/TEST_hcom2_coptr.csv
```
### The plots are available at
```{bash}
s3://genomics-workflow-core/Results/coptr/TEST/plots-dir/
```
